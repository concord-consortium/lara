import * as iframePhone from "iframe-phone";
import {
  IJobInfo, IJobExecutor, ICreateJobRequest, ICreateJobResponse,
  ICancelJobRequest, IJobInfoMessage
} from "../interactive-api-shared/types";

export class JobManager {
  private executor: IJobExecutor;
  private phones: Map<string, iframePhone.IFrameEndpoint> = new Map();
  private contexts: Map<string, Record<string, any>> = new Map();
  private jobToInteractive: Map<string, string> = new Map();

  constructor(executor: IJobExecutor) {
    this.executor = executor;
    this.executor.onJobUpdate((job: IJobInfo) => {
      this.handleJobUpdate(job);
    });
  }

  public addInteractive(interactiveId: string, phone: iframePhone.IFrameEndpoint, context?: Record<string, any>): void {
    this.phones.set(interactiveId, phone);
    if (context) {
      this.contexts.set(interactiveId, context);
    }

    phone.addListener("createJob", (request: ICreateJobRequest) => {
      this.handleCreateJob(interactiveId, request);
    });

    phone.addListener("cancelJob", (request: ICancelJobRequest) => {
      this.handleCancelJob(request);
    });

    // Backfill: query executor for existing jobs (async, not awaited)
    this.backfillJobs(interactiveId, phone);
  }

  public removeInteractive(interactiveId: string): void {
    this.phones.delete(interactiveId);
    this.contexts.delete(interactiveId);

    // Drop routing mappings for this interactive's jobs
    const jobsToRemove: string[] = [];
    this.jobToInteractive.forEach((iId, jobId) => {
      if (iId === interactiveId) {
        jobsToRemove.push(jobId);
      }
    });
    jobsToRemove.forEach(jobId => {
      this.jobToInteractive.delete(jobId);
    });
  }

  private async backfillJobs(interactiveId: string, phone: iframePhone.IFrameEndpoint): Promise<void> {
    try {
      const context = this.contexts.get(interactiveId);
      const existingJobs = await this.executor.getJobs(context);
      for (const job of existingJobs) {
        this.jobToInteractive.set(job.id, interactiveId);
        const message: IJobInfoMessage = { job };
        phone.post("jobInfo", message);
      }
    } catch (e) {
      // Silently discard — backfill is best-effort
    }
  }

  private async handleCreateJob(interactiveId: string, request: ICreateJobRequest): Promise<void> {
    const context = this.contexts.get(interactiveId);
    const job = await this.executor.createJob(request.request, context);
    this.jobToInteractive.set(job.id, interactiveId);

    const response: ICreateJobResponse = {
      requestId: request.requestId,
      job
    };

    const phone = this.phones.get(interactiveId);
    if (phone) {
      phone.post("jobCreated", response);
    }
  }

  private async handleCancelJob(request: ICancelJobRequest): Promise<void> {
    try {
      await this.executor.cancelJob(request.jobId);
    } catch (e) {
      // Silently discard — fire-and-forget, no response channel
    }
  }

  private handleJobUpdate(job: IJobInfo): void {
    const interactiveId = this.jobToInteractive.get(job.id);
    if (!interactiveId) {
      // Unknown job ID — silently discard
      return;
    }

    const phone = this.phones.get(interactiveId);
    if (!phone) {
      // Interactive removed — silently discard
      return;
    }

    const message: IJobInfoMessage = { job };
    phone.post("jobInfo", message);
  }
}
