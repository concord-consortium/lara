import { IAnswerMetadataWithAttachmentsInfo } from "./types";
import { AttachmentsManager } from "./attachments-manager";
import { setAttachmentsManagerTimeout, initializeAttachmentsManager } from "./attachments-manager-global";
import { handleGetAttachmentUrl, findFolder } from "./handle-get-attachment-url";
import { IAttachmentsManagerInitOptions, IHandleGetAttachmentUrlOptions } from "./types";

const mockCreateFolder = jest.fn(() => Promise.resolve({
  id: "folder-id", readWriteToken: "read-write-token", ownerId: "testRunKey"
}));
const mockSignedWriteUrl = "https://concord.org/write/url";
const mockSignedWriteUrlResponse = [
  mockSignedWriteUrl, { folder: { id: "folder-id", ownerId: "testRunKey" }, publicPath: "public/path" }
];
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

describe("findFolder", () => {
  it("returns a folder that has ownerId matching learnerId", () => {
    const answerMeta1: IAnswerMetadataWithAttachmentsInfo = {
      attachments: {
        foo: {
          publicPath: "1/1",
          folder: {
            id: "1",
            ownerId: "user-1"
          }
        },
        bar: {
          publicPath: "2/2",
          folder: {
            id: "2",
            ownerId: "classmate-1"
          }
        },
      }
    };
    expect(findFolder(answerMeta1, "foo", "user-1")).toEqual({
      id: "1",
      ownerId: "user-1"
    });

    const answerMeta2: IAnswerMetadataWithAttachmentsInfo = {
      attachments: {
        foo: {
          publicPath: "1/1",
          folder: {
            id: "1",
            ownerId: "classmate-1"
          }
        },
        bar: {
          publicPath: "2/2",
          folder: {
            id: "2",
            ownerId: "user-1"
          }
        },
      }
    };
    expect(findFolder(answerMeta2, "foo", "user-1")).toEqual({
      id: "2",
      ownerId: "user-1"
    });
  });

  it("returns null if it's not possible to find a folder that has ownerId matching learnerId", () => {
    const answerMeta1: IAnswerMetadataWithAttachmentsInfo = {
      attachments: {}
    };
    expect(findFolder(answerMeta1, "foo", "user-1")).toEqual(null);

    const answerMeta2: IAnswerMetadataWithAttachmentsInfo = {
      attachments: {
        foo: {
          publicPath: "1/1",
          folder: {
            id: "1",
            ownerId: "classmate-1"
          }
        },
        bar: {
          publicPath: "2/2",
          folder: {
            id: "2",
            ownerId: "classmate-2"
          }
        }
      }
    };
    expect(findFolder(answerMeta2, "foo", "user-1")).toEqual(null);
  });
});

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

      expect(response).toEqual({
        url: "https://concord.org/write/url",
        requestId: 1
      });

      expect(mockCreateFolder).toHaveBeenCalled();
      expect(mockGetSignedWriteUrl).toHaveBeenCalled();
      expect(options.writeOptions?.onAnswerMetaUpdate).toHaveBeenCalledWith({
        attachments: {
          "test.json": {
            folder: {id: "folder-id", ownerId: "testRunKey"},
            publicPath: "public/path"
          }
        }
      });
      // Ensure that the original answer meta hasn't been modified.
      expect(options.answerMeta).toEqual({});
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
        attachments: { "test.json": { publicPath: "public/path", folder: { id: "folder-id", ownerId: "testRunKey" } } },
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
