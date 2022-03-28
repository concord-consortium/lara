import * as React from "react";
import { useState, useEffect } from "react";
import { getAttachmentUrl, IRuntimeInitInteractive, writeAttachment, WriteAttachmentParams } from "../../../interactive-api-client";

interface Props {
  initMessage: IRuntimeInitInteractive<any, {}>;
}

interface AttachmentInfo {
  url?: string;
  err?: any;
}
type AttachmentMap = Record<string, AttachmentInfo>;

export const RuntimeComponent: React.FC<Props> = ({initMessage}) => {
  const [uploading, setUploading] = useState<boolean>(false);
  const [attachments, setAttachments] = useState<AttachmentMap>({});

  useEffect(() => {
    const initialAttachments: AttachmentMap = {};
    if (initMessage.metadata?.attachments) {
      Object.keys(initMessage.metadata.attachments).forEach(key => initialAttachments[key] = {});
    }
    setAttachments(initialAttachments);
  }, [initMessage]);

  useEffect(() => {
    const getUrls = async () => {
      const names = Object.keys(attachments);
      for await (const name of names) {
        const attachment = attachments[name];
        if (!attachment.url) {
          try {
            const url = await getAttachmentUrl({name});
            setAttachments(map => ({...map, [name]: {url}}));
          } catch (err) {
            // tslint:disable-next-line:no-console
            console.error(`Unable to get attachment url: ${err}`);
            setAttachments(map => ({...map, [name]: {err}}));
          }
        }
      }
    };

    getUrls().catch(alert);
  }, [attachments]);

  const handleUploadAttachment = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = async () => {
        const params: WriteAttachmentParams = {
          name: file.name,
          content: reader.result,
          contentType: file.type,
        };
        try {
          setUploading(true);
          const response = await writeAttachment(params);
          if (response.ok) {
            setAttachments(map => ({...map, [file.name]: {}}));
          }
        } catch (err) {
          alert(`Unable to save attachment: ${err}`);
          setAttachments(map => ({...map, [file.name]: {err}}));
        } finally {
          setUploading(false);
        }
      };
      reader.readAsArrayBuffer(file);
    }
  };

  const renderAttachmentUrls = () => {
    const names = Object.keys(attachments);
    if (names.length > 0) {
      return (
        <ul>
          {names.map(name => {
            const {url, err} = attachments[name];
            return (
              <li key={name}>
                {name}: {url ? <audio controls={true} src={url} /> : (err?.toString() || "Loading...")}
              </li>
            );
          })}
        </ul>
      );
    }
  };

  return (
    <div className="padded">
      <h1>Attachments Example Interactve</h1>

      <fieldset>
        <legend>Audio Attachments</legend>
        <input type="file" title="Upload Audio File" accept="audio/*" onChange={handleUploadAttachment} />

        {uploading ? <p>Uploading...</p> : null}

        {renderAttachmentUrls()}
      </fieldset>

      <fieldset>
        <legend>Runtime Init Message</legend>
        <div className="padded monospace pre">{JSON.stringify(initMessage, null, 2)}</div>
      </fieldset>
    </div>
  );
};
