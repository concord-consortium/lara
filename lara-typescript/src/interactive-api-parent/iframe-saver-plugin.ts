import { IFrameSaverClientMessage } from "../interactive-api-client";

export interface IFrameSaverPlugin {
  listeners: Partial<Record<IFrameSaverClientMessage, (content: any) => void>>;
}
