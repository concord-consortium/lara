import {
  PubSubMessageHandler, PubSubChannelInfoHandler, IPubSubCreateChannel,
  IPubSubPublish, IPubSubSubscribe, IPubSubUnsubscribe, IPubSubMessage, IPubSubChannelInfo
} from "./types";
import { Client } from "./client";
import { nanoid } from "nanoid";

export class PubSubChannel {
  private client: Client;
  private channelId: string;
  private channelInfo: any;
  private subscriptions: Map<string, {
    handler: PubSubMessageHandler;
    channelInfoHandler?: PubSubChannelInfoHandler;
  }> = new Map();
  private listenersRegistered: boolean = false;

  constructor(client: Client, channelId: string, channelInfo?: any) {
    this.client = client;
    this.channelId = channelId;
    this.channelInfo = channelInfo;

    // Always create the channel on construction
    this.createChannel();
  }

  public publish(message: any): void {
    const publishMessage: IPubSubPublish = {
      channelId: this.channelId,
      message,
      timestamp: Date.now()
    };

    this.client.post("publish", publishMessage);
  }

  public subscribe(
    handler: PubSubMessageHandler,
    onChannelInfo?: PubSubChannelInfoHandler
  ): () => void {
    const subscriptionId = nanoid();

    // Store handlers locally
    this.subscriptions.set(subscriptionId, {
      handler,
      channelInfoHandler: onChannelInfo
    });

    // Register listeners for pubSubMessage and pubSubChannelInfo if not already done
    if (!this.listenersRegistered) {
      this.registerListeners();
    }

    // Send subscribe message to host
    const subscribeMessage: IPubSubSubscribe = {
      channelId: this.channelId,
      subscriptionId
    };

    this.client.post("subscribe", subscribeMessage);

    // Return unsubscribe function
    return () => {
      this.unsubscribe(subscriptionId);
    };
  }

  public dispose(): void {
    // Unsubscribe all subscriptions
    const subscriptionIds = Array.from(this.subscriptions.keys());
    subscriptionIds.forEach((subscriptionId) => {
      this.unsubscribe(subscriptionId);
    });
  }

  public getChannelId(): string {
    return this.channelId;
  }

  public getChannelInfo(): any {
    return this.channelInfo;
  }

  public setChannelInfo(channelInfo: any): void {
    this.channelInfo = channelInfo;
    this.createChannel();
  }

  private registerListeners(): void {
    // Listen for pubSubMessage events for this channel
    this.client.addListener("pubSubMessage", (content: IPubSubMessage) => {
      if (content.channelId === this.channelId) {
        this.subscriptions.forEach((subscription) => {
          subscription.handler(content.message, content.publisherId);
        });
      }
    });

    // Listen for pubSubChannelInfo events for this channel
    this.client.addListener("pubSubChannelInfo", (content: IPubSubChannelInfo) => {
      if (content.channelId === this.channelId) {
        this.subscriptions.forEach((subscription) => {
          if (subscription.channelInfoHandler) {
            subscription.channelInfoHandler(content.channelInfo);
          }
        });
      }
    });

    this.listenersRegistered = true;
  }

  private createChannel(): void {
    const createMessage: IPubSubCreateChannel = {
      channelId: this.channelId,
      channelInfo: this.channelInfo,
      timestamp: Date.now()
    };

    this.client.post("createChannel", createMessage);
  }

  private unsubscribe(subscriptionId: string): void {
    // Remove local reference
    this.subscriptions.delete(subscriptionId);

    // Send unsubscribe message to host
    const unsubscribeMessage: IPubSubUnsubscribe = {
      channelId: this.channelId,
      subscriptionId
    };

    this.client.post("unsubscribe", unsubscribeMessage);
  }
}
