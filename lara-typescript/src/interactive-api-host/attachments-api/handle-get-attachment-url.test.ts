import { AttachmentsManager } from "./attachments-manager";
import { setAttachmentsManagerTimeout, initializeAttachmentsManager } from "./attachments-manager-global";
import { handleGetAttachmentUrl } from "./handle-get-attachment-url";
import { IAttachmentsManagerInitOptions, IHandleGetAttachmentUrlOptions } from "./types";

const mockCreateFolder = jest.fn(() => Promise.resolve({ id: "folder-id", readWriteToken: "read-write-token" }));
const mockSignedWriteUrl = "https://concord.org/write/url";
const mockSignedWriteUrlResponse = [mockSignedWriteUrl, { folder: { id: "folder-id" }, publicPath: "public/path" }];
const mockGetSignedWriteUrl = jest.fn(() => Promise.resolve(mockSignedWriteUrlResponse));
const mockSignedReadUrl = "https://concord.org/read/url";
const mockGetSignedReadUrl = jest.fn(() => Promise.resolve(mockSignedReadUrl));

jest.mock("./attachments-manager", () => ({
  ...jest.requireActual("./attachments-manager"),
  AttachmentsManager: class AttachmentsManagerMock
    extends jest.requireActual("./attachments-manager").AttachmentsManager {
    constructor(options: IAttachmentsManagerInitOptions) {
      super(options);
      this.createFolder = mockCreateFolder;
      this.getSignedReadUrl = mockGetSignedReadUrl;
      this.getSignedWriteUrl = mockGetSignedWriteUrl;
    }
  }
}));

let attachmentsManagerOptions: IAttachmentsManagerInitOptions | null = null;
jest.mock("./attachments-manager-global", () => ({
  ...jest.requireActual("./attachments-manager-global"),
  getAttachmentsManager: () =>
    attachmentsManagerOptions
      ? Promise.resolve(new AttachmentsManager(attachmentsManagerOptions))
      : Promise.reject("AttachmentsManager hasn't been initialized"),
  initializeAttachmentsManager: (options: IAttachmentsManagerInitOptions) => attachmentsManagerOptions = options
}));

describe("handleGetAttachmentUrl", () => {
  beforeEach(() => {
    attachmentsManagerOptions = null;
  });

  describe("errors handling", () => {
    it("returns an error if attachments manager hasn't been initialized", async () => {
      setAttachmentsManagerTimeout(200);

      const response = await handleGetAttachmentUrl({
        request: {
          requestId: 1,
          name: "test.json",
          operation: "write",
        },
        answerMeta: {}
      });
      expect(response).toEqual({
        error: "error getting attachment url: the host environment did not initialize the attachments manager",
        requestId: 1
      });
    });

    it("returns an error for write requests if attachments manager doesn't support write operation", async () => {
        initializeAttachmentsManager({
          tokenServiceEnv: "dev"
        });

        const response = await handleGetAttachmentUrl({
          request: {
            requestId: 1,
            name: "test.json",
            operation: "write",
          },
          answerMeta: {}
        });
        expect(response).toEqual({
          error: "error getting attachment url: the write operation is not supported by the host environment",
          requestId: 1
        });
    });

    it("returns an error for read requests if answer metadata doesn't have attachments info", async () => {
      initializeAttachmentsManager({
        tokenServiceEnv: "dev"
      });

      const response = await handleGetAttachmentUrl({
        request: {
          requestId: 1,
          name: "test.json",
          operation: "read",
        },
        answerMeta: {}
      });
      expect(response).toEqual({
        error: `error getting attachment url: test.json ["No attachment info in answer metadata"]`,
        requestId: 1
      });
    });
  });

  describe("valid requests handling", () => {
    it("handles write operation requests", async () => {
      initializeAttachmentsManager({
        tokenServiceEnv: "dev",
        writeOptions: {
          runKey: "testRunKey"
        }
      });

      const options: IHandleGetAttachmentUrlOptions = {
        request: {
          requestId: 1,
          name: "test.json",
          operation: "write",
        },
        writeOptions: {
          interactiveId: "testInteractiveId",
          onAnswerMetaUpdate: jest.fn()
        },
        answerMeta: {}
      };
      const response = await handleGetAttachmentUrl(options);

      expect(mockCreateFolder).toHaveBeenCalled();
      expect(mockGetSignedWriteUrl).toHaveBeenCalled();
      expect(options.writeOptions?.onAnswerMetaUpdate).toHaveBeenCalled();

      expect(response).toEqual({
        url: "https://concord.org/write/url",
        requestId: 1
      });
    });
  });

  it("handles read operation requests", async () => {
    initializeAttachmentsManager({
      tokenServiceEnv: "dev",
      writeOptions: {
        runKey: "testRunKey"
      }
    });

    const options: IHandleGetAttachmentUrlOptions = {
      request: {
        requestId: 1,
        name: "test.json",
        operation: "read",
      },
      writeOptions: {
        interactiveId: "testInteractiveId",
        onAnswerMetaUpdate: jest.fn()
      },
      answerMeta: {
        attachments: { "test.json": { folder: { id: "folder-id" }, publicPath: "public/path" } },
        attachmentsFolder: { id: "folder-id" }
      }
    };
    const response = await handleGetAttachmentUrl(options);

    expect(mockGetSignedReadUrl).toHaveBeenCalled();
    expect(options.writeOptions?.onAnswerMetaUpdate).not.toHaveBeenCalled();

    expect(response).toEqual({
      url: "https://concord.org/read/url",
      requestId: 1
    });
  });
});
