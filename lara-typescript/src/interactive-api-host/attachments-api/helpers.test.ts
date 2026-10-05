import { answerMetadataToAttachmentInfoMap, getJwtLifetime } from "./helpers";
import { base64url } from "./test-utils";
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

  describe("getJwtLifetime", () => {
    const jwtWithPayload = (payload: string) => `header.${base64url(payload)}.signature`;

    it("reads exp minus iat from a base64url payload", () => {
      // this payload encodes to base64url containing "-", which plain atob rejects
      const jwt = jwtWithPayload(JSON.stringify({ iat: 1700000000, exp: 1700003600, uid: "user?>>0" }));
      expect(jwt).toMatch(/-/);
      expect(getJwtLifetime(jwt)).toBe(3600);
    });

    it("returns undefined when exp or iat cannot be read", () => {
      expect(getJwtLifetime(undefined)).toBeUndefined();
      expect(getJwtLifetime("rawFirebaseJWT")).toBeUndefined();
      expect(getJwtLifetime("header.!!!.signature")).toBeUndefined();
      expect(getJwtLifetime(jwtWithPayload("not json"))).toBeUndefined();
      expect(getJwtLifetime(jwtWithPayload(JSON.stringify({ iat: 1700000000, exp: "1700003600" })))).toBeUndefined();
      expect(getJwtLifetime(jwtWithPayload(JSON.stringify({ iat: "1700000000", exp: 1700003600 })))).toBeUndefined();
      expect(getJwtLifetime(jwtWithPayload(JSON.stringify({ exp: 1700003600 })))).toBeUndefined();
    });
  });
});
