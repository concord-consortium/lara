import { JobManager } from "./job-manager";
import { IJobInfo, IJobExecutor } from "../interactive-api-shared/types";

interface MockPhone {
  post: jest.Mock;
  addListener: jest.Mock;
}

const createMockPhone = (): MockPhone => ({
  post: jest.fn(),
  addListener: jest.fn()
});

const createMockJob = (overrides?: Partial<IJobInfo>): IJobInfo => ({
  version: 1,
  id: "job-1",
  status: "queued",
  request: { task: "generate" },
  createdAt: Date.now(),
  ...overrides
});

interface MockExecutor extends IJobExecutor {
  _jobUpdateCallback: ((job: IJobInfo) => void) | null;
  _simulateJobUpdate: (job: IJobInfo) => void;
}

const createMockExecutor = (existingJobs: IJobInfo[] = []): MockExecutor => {
  const executor: MockExecutor = {
    createJob: jest.fn().mockImplementation(async (request) => createMockJob({ request })),
    cancelJob: jest.fn().mockResolvedValue(undefined),
    getJobs: jest.fn().mockResolvedValue(existingJobs),
    onJobUpdate: jest.fn().mockImplementation((callback) => {
      executor._jobUpdateCallback = callback;
    }),
    _jobUpdateCallback: null,
    _simulateJobUpdate: (job: IJobInfo) => {
      if (executor._jobUpdateCallback) {
        executor._jobUpdateCallback(job);
      }
    }
  };
  return executor;
};

const getListener = (phone: MockPhone, message: string) => {
  const call = phone.addListener.mock.calls.find((c: any[]) => c[0] === message);
  return call[1];
};

const flushPromises = () => new Promise(resolve => setTimeout(resolve, 0));

describe("JobManager", () => {
  it("registers onJobUpdate callback on constructor", () => {
    const executor = createMockExecutor();
    const _manager = new JobManager(executor); // tslint:disable-line:no-unused-variable
    expect(executor.onJobUpdate).toHaveBeenCalledTimes(1);
  });

  it("registers phone listeners on addInteractive", () => {
    const executor = createMockExecutor();
    const manager = new JobManager(executor);
    const phone = createMockPhone();

    manager.addInteractive("int-1", phone as any);

    expect(phone.addListener).toHaveBeenCalledWith("createJob", expect.any(Function));
    expect(phone.addListener).toHaveBeenCalledWith("cancelJob", expect.any(Function));
  });

  it("backfills existing jobs on addInteractive", async () => {
    const existingJob = createMockJob({ id: "existing-1" });
    const executor = createMockExecutor([existingJob]);
    const manager = new JobManager(executor);
    const phone = createMockPhone();

    manager.addInteractive("int-1", phone as any, { userId: "user-1" });
    await flushPromises();

    expect(executor.getJobs).toHaveBeenCalledWith({ userId: "user-1" });
    expect(phone.post).toHaveBeenCalledWith("jobInfo", { job: existingJob });
  });

  it("passes context to getJobs during backfill", async () => {
    const executor = createMockExecutor();
    const manager = new JobManager(executor);
    const phone = createMockPhone();
    const context = { resourceId: "res-1", userId: "user-1" };

    manager.addInteractive("int-1", phone as any, context);
    await flushPromises();

    expect(executor.getJobs).toHaveBeenCalledWith(context);
  });

  it("calls getJobs with undefined context when none provided", async () => {
    const executor = createMockExecutor();
    const manager = new JobManager(executor);
    const phone = createMockPhone();

    manager.addInteractive("int-1", phone as any);
    await flushPromises();

    expect(executor.getJobs).toHaveBeenCalledWith(undefined);
  });

  it("routes createJob to executor and sends response", async () => {
    const createdJob = createMockJob({ id: "new-job" });
    const executor = createMockExecutor();
    (executor.createJob as jest.Mock).mockResolvedValue(createdJob);
    const manager = new JobManager(executor);
    const phone = createMockPhone();

    manager.addInteractive("int-1", phone as any, { userId: "user-1" });

    getListener(phone, "createJob")({ requestId: 42, request: { task: "generate" } });
    await flushPromises();

    expect(executor.createJob).toHaveBeenCalledWith({ task: "generate" }, { userId: "user-1" });
    expect(phone.post).toHaveBeenCalledWith("jobCreated", {
      requestId: 42,
      job: createdJob
    });
  });

  it("routes cancelJob to executor", async () => {
    const executor = createMockExecutor();
    const manager = new JobManager(executor);
    const phone = createMockPhone();

    manager.addInteractive("int-1", phone as any);

    getListener(phone, "cancelJob")({ jobId: "job-1" });
    await flushPromises();

    expect(executor.cancelJob).toHaveBeenCalledWith("job-1");
  });

  it("silently catches cancelJob executor rejection", async () => {
    const executor = createMockExecutor();
    (executor.cancelJob as jest.Mock).mockRejectedValue(new Error("cancel failed"));
    const manager = new JobManager(executor);
    const phone = createMockPhone();

    manager.addInteractive("int-1", phone as any);

    getListener(phone, "cancelJob")({ jobId: "job-1" });
    // Should not throw
    await flushPromises();

    expect(executor.cancelJob).toHaveBeenCalledWith("job-1");
  });

  it("routes onJobUpdate to correct interactive", async () => {
    const executor = createMockExecutor();
    const createdJob = createMockJob({ id: "job-1" });
    (executor.createJob as jest.Mock).mockResolvedValue(createdJob);
    const manager = new JobManager(executor);
    const phone = createMockPhone();

    manager.addInteractive("int-1", phone as any);

    // Create a job to establish the routing mapping
    getListener(phone, "createJob")({ requestId: 1, request: { task: "generate" } });
    await flushPromises();
    phone.post.mockClear();

    // Simulate job update
    const updatedJob = { ...createdJob, status: "running" as const, updatedAt: 2000 };
    executor._simulateJobUpdate(updatedJob);

    expect(phone.post).toHaveBeenCalledWith("jobInfo", { job: updatedJob });
  });

  it("silently discards onJobUpdate for unknown job IDs", () => {
    const executor = createMockExecutor();
    const manager = new JobManager(executor);
    const phone = createMockPhone();

    manager.addInteractive("int-1", phone as any);
    phone.post.mockClear();

    executor._simulateJobUpdate(createMockJob({ id: "unknown-job" }));

    expect(phone.post).not.toHaveBeenCalled();
  });

  it("removes phone and routing mappings on removeInteractive", async () => {
    const executor = createMockExecutor();
    const createdJob = createMockJob({ id: "job-1" });
    (executor.createJob as jest.Mock).mockResolvedValue(createdJob);
    const manager = new JobManager(executor);
    const phone = createMockPhone();

    manager.addInteractive("int-1", phone as any);

    getListener(phone, "createJob")({ requestId: 1, request: { task: "generate" } });
    await flushPromises();
    phone.post.mockClear();

    manager.removeInteractive("int-1");

    // Subsequent job update should be discarded
    executor._simulateJobUpdate({ ...createdJob, status: "running" as const });
    expect(phone.post).not.toHaveBeenCalled();
  });

  it("routes jobs to correct interactive with multiple interactives", async () => {
    const executor = createMockExecutor();
    const manager = new JobManager(executor);
    const phone1 = createMockPhone();
    const phone2 = createMockPhone();

    const job1 = createMockJob({ id: "job-1" });
    const job2 = createMockJob({ id: "job-2" });
    (executor.createJob as jest.Mock)
      .mockResolvedValueOnce(job1)
      .mockResolvedValueOnce(job2);

    manager.addInteractive("int-1", phone1 as any);
    manager.addInteractive("int-2", phone2 as any);

    // Create job from int-1
    getListener(phone1, "createJob")({ requestId: 1, request: { task: "a" } });
    await flushPromises();

    // Create job from int-2
    getListener(phone2, "createJob")({ requestId: 1, request: { task: "b" } });
    await flushPromises();

    phone1.post.mockClear();
    phone2.post.mockClear();

    // Update job-1 should go to int-1 only
    const updatedJob1 = { ...job1, status: "success" as const };
    executor._simulateJobUpdate(updatedJob1);
    expect(phone1.post).toHaveBeenCalledWith("jobInfo", { job: updatedJob1 });
    expect(phone2.post).not.toHaveBeenCalled();

    phone1.post.mockClear();

    // Update job-2 should go to int-2 only
    const updatedJob2 = { ...job2, status: "success" as const };
    executor._simulateJobUpdate(updatedJob2);
    expect(phone2.post).toHaveBeenCalledWith("jobInfo", { job: updatedJob2 });
    expect(phone1.post).not.toHaveBeenCalled();
  });

  it("silently discards backfill errors", async () => {
    const executor = createMockExecutor();
    (executor.getJobs as jest.Mock).mockRejectedValue(new Error("backfill failed"));
    const manager = new JobManager(executor);
    const phone = createMockPhone();

    manager.addInteractive("int-1", phone as any);
    await flushPromises();

    expect(phone.post).not.toHaveBeenCalled();
  });

  it("stores routing mappings for backfilled jobs", async () => {
    const existingJob = createMockJob({ id: "backfill-1" });
    const executor = createMockExecutor([existingJob]);
    const manager = new JobManager(executor);
    const phone = createMockPhone();

    manager.addInteractive("int-1", phone as any);
    await flushPromises();
    phone.post.mockClear();

    // Job update for backfilled job should route correctly
    const updatedJob = { ...existingJob, status: "running" as const };
    executor._simulateJobUpdate(updatedJob);
    expect(phone.post).toHaveBeenCalledWith("jobInfo", { job: updatedJob });
  });
});
