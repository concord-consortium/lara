import * as React from "react";
import { useState, useEffect } from "react";
import { getAttachmentUrl, IRuntimeInitInteractive, writeAttachment, WriteAttachmentParams, IAttachmentInfo } from "../../../interactive-api-client";

interface Props {
  initMessage: IRuntimeInitInteractive<any, {}>;
}

interface UserAttachmentInfo extends IAttachmentInfo {
  url?: string;
  err?: any;
  loading?: boolean;
}
type UserAttachmentMap = Record<string, UserAttachmentInfo>;

export const RuntimeComponent: React.FC<Props> = ({initMessage}) => {
  const [uploading, setUploading] = useState<boolean>(false);
  const [attachments, setAttachments] = useState<UserAttachmentMap>({});

  // for now this is the best way to know in authoring runtime mode
  const inAuthoringRuntimeMode = !initMessage.hostFeatures.getFirebaseJwt;

  useEffect(() => {
    const initialAttachments: UserAttachmentMap = {};
    if (initMessage.attachments) {
      Object.keys(initMessage.attachments).forEach(key => initialAttachments[key] = {});
    }
    setAttachments(initialAttachments);
  }, [initMessage]);

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

  const loadAttachment = async (name: string) => {
    const attachment = attachments[name];
    if (!attachment.url) {
      setAttachments(map => ({...map, [name]: {loading: true}}));
      try {
        const url = await getAttachmentUrl({name});
        setAttachments(map => ({...map, [name]: {url, loading: false}}));
      } catch (err) {
        // tslint:disable-next-line:no-console
        console.error(`Unable to get attachment url: ${err}`);
        setAttachments(map => ({...map, [name]: {err}}));
      }
    }
  };

  const renderAttachmentUrl = (name: string) => {
    const {url, err, loading} = attachments[name];
    let content: JSX.Element;

    const handleLoadAttachment = () => loadAttachment(name);
    const clickHereStyle: React.CSSProperties = {
      cursor: "pointer",
      textDecoration: "underline",
    };

    if (loading) {
      content = <span>Loading...</span>;
    } else if (url) {
      content = <audio controls={true} src={url} />;
    } else if (err) {
      content = <span style={clickHereStyle} onClick={handleLoadAttachment}>{err.toString()}</span>;
    } else {
      content = <span style={clickHereStyle} onClick={handleLoadAttachment}>Click to here to load...</span>;
    }

    return <li key={name}><span style={{fontWeight: "bold"}}>{name}</span>: {content}</li>;
  };

  const renderAttachmentUrls = () => {
    const names = Object.keys(attachments);
    if (names.length > 0) {
      return (
        <ul>
          {names.map(name => renderAttachmentUrl(name))}
        </ul>
      );
    }
  };

  return (
    <div className="padded">
      <h1>Attachments Example Interactive</h1>

      <fieldset>
        <legend>Audio Attachments</legend>

        {inAuthoringRuntimeMode
          ? <p>When this interactive is used by a student an upload button will be visible here.</p>
          : <input type="file" title="Upload Audio File" accept="audio/*" onChange={handleUploadAttachment} />
        }

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
