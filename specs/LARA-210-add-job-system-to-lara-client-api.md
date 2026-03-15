# Add Job System to LARA Interactive API

**Jira**: https://concord-consortium.atlassian.net/browse/LARA-210

**Status**: **Closed**

## Overview

Add a job system to the LARA interactive API, enabling iframed interactives to create named background jobs, cancel them, and receive real-time status updates through their lifecycle. The client provides a `useJobs()` React hook and imperative API functions; the host provides a `JobManager` class with a pluggable `IJobExecutor` interface for backend-agnostic job execution. Jobs are backfilled on reconnect (provided the host supplies stable context), so they can survive page reloads.

## Requirements

- Clients must be able to create a job by sending a request object containing `{ task: string }` plus any additional parameters
- `createJob()` must return a `Promise` that resolves with the full job info (including host-assigned `id`) once the host acknowledges creation
- Clients must be able to listen for status updates on all jobs they have created via a unified listener (one listener endpoint for all jobs, rather than per-job listeners; multiple listener registrations are supported)
- A `useJobs()` React hook must be provided that returns:
  - `createJob` -- function to create a job (returns Promise)
  - `cancelJob` -- function to cancel a job by ID (fire-and-forget; host sends back a job update with `"cancelled"` status)
  - `jobs` -- reactive array of all known jobs (including backfilled jobs from previous sessions), in arrival order, updated as status changes arrive. No client-side sorting is performed -- consumers can sort by `createdAt` if needed
  - `latestJob` -- last element of the `jobs` array (`IJobInfo | undefined`), convenience accessor for `jobs.at(-1)`
- On connect, the host backfills the interactive with its existing jobs (via `getJobs` on the executor). This enables jobs to survive page reloads -- the interactive receives its previously created jobs as `"jobInfo"` messages when it reconnects, provided the executor and host supply stable context for `getJobs`
- The API must define the following TypeScript interface for job info:
  ```typescript
  interface IJobInfo {
    version: 1;
    id: string;
    status: "queued" | "running" | "success" | "failure" | "cancelled";
    request: { task: string } & Record<string, any>;
    result?: { message: string; processingMessage?: string } & Record<string, any>;
    createdAt: number;
    updatedAt?: number;
    startedAt?: number;
    completedAt?: number;
  }
  ```
- New message types must be added:
  - `IRuntimeClientMessage`: `"createJob"`, `"cancelJob"`
  - `IRuntimeServerMessage`: `"jobCreated"` (creation response), `"jobInfo"` (backfill on connect + ongoing status updates)
- `cancelJob(jobId)` must send a cancellation request to the host (fire-and-forget, no ack/response); the host communicates the result via a `jobInfo` message with `status: "cancelled"`
- The client API must expose imperative functions:
  - `createJob(request: { task: string } & Record<string, any>): Promise<IJobInfo>` -- create a job
  - `cancelJob(jobId: string): void` -- cancel a job (fire-and-forget)
  - `getJobs(): IJobInfo[]` -- synchronously return the current jobs array from client-managed state
  - `addJobUpdateListener(callback: (job: IJobInfo) => void): void` -- listen for job info messages
  - `removeJobUpdateListener(callback: (job: IJobInfo) => void): void` -- remove a specific listener
- A host-side `JobManager` class must be provided in `interactive-api-host`, following the `PubSubManager` pattern:
  - Constructor takes an `IJobExecutor` instance (pluggable backend)
  - `addInteractive(interactiveId, phone, context?)` -- register an interactive's iframe-phone endpoint with an optional context object passed through to the executor for `createJob` and `getJobs` calls
  - `removeInteractive(interactiveId)` -- unregister an interactive, drop routing mappings for its jobs
  - Listens for `"createJob"` and `"cancelJob"` messages from registered interactives
  - Delegates job creation and cancellation to the injected `IJobExecutor`
  - Forwards `"jobCreated"` and `"jobInfo"` messages back to the originating interactive's iframe-phone endpoint
  - On `addInteractive`, queries the executor for existing jobs (via `getJobs`) and sends each as a `"jobInfo"` message to the interactive (backfill on connect)
  - `JobManager` is a thin message routing layer -- it owns no job state and contains no business logic
- The API must define the following `IJobExecutor` interface:
  ```typescript
  interface IJobExecutor {
    createJob(request: { task: string } & Record<string, any>, context?: Record<string, any>): Promise<IJobInfo>;
    cancelJob(jobId: string): Promise<void>;
    getJobs(context?: Record<string, any>): Promise<IJobInfo[]>;
    onJobUpdate(callback: (job: IJobInfo) => void): void;
  }
  ```
  - `createJob` accepts an optional second `context` parameter containing host-provided metadata. The context is opaque to the API -- `JobManager` passes it through to the executor
  - `createJob` is async and must always resolve (never reject) -- it returns an `IJobInfo` with `status: "queued"` on success, or `status: "failure"` with a descriptive `result.message` on error
  - `getJobs` returns existing jobs matching the given context
  - `cancelJob` is async -- the executor initiates cancellation; the result is communicated via a subsequent `onJobUpdate` callback with `status: "cancelled"`
  - `onJobUpdate` registers a callback that the executor calls whenever a job's status changes
  - The executor owns all job state -- it is responsible for ID generation, status tracking, and communication with the actual backend
- `JobManager` and `IJobExecutor` must be exported from `interactive-api-host/index.ts`

## Technical Notes

- Message types are defined as string literal unions in `interactive-api-shared/types.ts`
- The existing request-response pattern uses `IBaseRequestResponse` with `requestId: number` for correlating requests and responses
- Job ID is host-generated (string), returned in the creation response -- differs from Pub/Sub where channel IDs are client-generated
- The `useJobs()` hook maintains local state of all jobs and replaces entries when `jobInfo` messages arrive from the host, matching by `id` (full snapshot replacement, no merge logic)
- The client `Client` class internally listens for `"jobInfo"` messages from the host, maintains a local jobs array in managed state, and emits local events. The imperative API reads from and listens to this local state -- no subscription message is sent to the host
- `createJob()` updates managed state and emits `"jobInfoReceived"` before resolving the Promise, so `getJobs()` is immediately consistent after `await createJob()`
- Race condition note: if the executor fires `onJobUpdate` during `createJob()` execution (before the Promise resolves), `JobManager` won't have the job ID routing mapping yet and will silently discard the update. The next `onJobUpdate` will carry the full snapshot
- `JobManager` follows the same structural pattern as `PubSubManager`: maintains a `phones` Map, registers message listeners on `addInteractive()`, cleans up on `removeInteractive()`
- `JobManager` tracks which interactive created each job (by job ID -> interactiveId mapping) so it can route `jobInfo` messages back to the correct interactive
- `IJobExecutor.onJobUpdate` supports a single callback -- `JobManager` registers it once in the constructor
- `JobManager` preserves the `requestId` from `ICreateJobRequest` in the `ICreateJobResponse` for standard request-response correlation
- If `executor.cancelJob()` rejects, `JobManager` catches and silently discards the error -- consistent with fire-and-forget semantics
- If the executor sends a job update for an unknown job ID, `JobManager` silently discards it
- `createJob()` has no timeout or rejection semantics -- consistent with all existing request-response functions in the API. Timeout handling is left to the consumer
- `useJobs()` supports multiple instances per interactive (same as `useInteractiveState`)
- `IJobInfo.version: 1` is for future-proofing only -- no validation is required in this version

## Out of Scope

- Concrete `IJobExecutor` implementations (Firebase Functions executor, mock executor) -- these are built by consuming applications (Activity Player, QI demo harness)
- Authorization, validation, and size limits for job requests -- these are executor/host concerns
- Job persistence beyond what the executor provides (the API supports backfill via `getJobs`, but storage is the executor's responsibility)
- Job retry or error recovery logic
- UI components for job status display
- Changes to the interactive-api-lara-host package
