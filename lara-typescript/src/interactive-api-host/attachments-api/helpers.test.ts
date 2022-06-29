import { answerMetadataToAttachmentInfoMap } from "./helpers";
import { IAnswerMetadataWithAttachmentsInfo } from "./types";

describe("helpers", () => {
  describe("answerMetadataToAttachmentInfoMap", () => {
    it("should handle undefined metadata", () => {
      expect(answerMetadataToAttachmentInfoMap(undefined)).toEqual({});
    });

    it("should handle metadata with no attachments", () => {
      expect(answerMetadataToAttachmentInfoMap({})).toEqual({});
    });

    it("should handle metadata with attachments", () => {
      const metadata: IAnswerMetadataWithAttachmentsInfo = {
        attachments: {
          "test.txt": {
            folder: {
              id: "1",
              ownerId: "user-1"
            },
            publicPath: "1/1",
            contentType: "text/plain"
          },
          "test.mp3": {
            folder: {
              id: "1",
              ownerId: "user-1"
            },
            publicPath: "1/2",
            contentType: "audio/mp3"
          }
        }
      };

      expect(answerMetadataToAttachmentInfoMap(metadata)).toEqual({
        "test.txt": {
          contentType: "text/plain"
        },
        "test.mp3": {
          contentType: "audio/mp3"
        }
      });
    });
  });
});
