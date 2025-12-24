import * as iframePhone from "iframe-phone";
import {
  IPubSubMessage, IPubSubChannelInfo
} from "../interactive-api-shared/types";

interface ChannelState {
  subscribers: Set<SubscriberInfo>;
  channelInfo?: any;
  lastPublishTime?: number;
}

interface SubscriberInfo {
  interactiveId: string;
  subscriptionId: string;
}

export class PubSubManager {
  private channels: Map<string, ChannelState> = new Map();
  private phones: Map<string, iframePhone.IFrameEndpoint> = new Map();

  constructor() {
    // Empty constructor
  }

  /**
   * Add an interactive with its iframe-phone endpoint.
   */
  public addInteractive(interactiveId: string, phone: iframePhone.IFrameEndpoint): void {
    this.phones.set(interactiveId, phone);
  }

  /**
   * Remove all subscriptions for a given interactive (e.g., when iframe is removed).
   * Also unregisters the phone endpoint.
   */
  public removeInteractive(interactiveId: string): void {
    // Unregister the phone endpoint
    this.phones.delete(interactiveId);

    // Remove all subscriptions for this interactive
    this.channels.forEach((channel: ChannelState, channelId: string) => {
      const toRemove: SubscriberInfo[] = [];

      channel.subscribers.forEach((subscriber: SubscriberInfo) => {
        if (subscriber.interactiveId === interactiveId) {
          toRemove.push(subscriber);
        }
      });

      toRemove.forEach((subscriber: SubscriberInfo) => {
        channel.subscribers.delete(subscriber);
      });

      // Clean up empty channels
      if (channel.subscribers.size === 0) {
        this.channels.delete(channelId);
      }
    });
  }

  /**
   * Create a channel with channelInfo.
   * Sets channelInfo only if the channel doesn't already exist.
   * Sends channelInfo to all current subscribers if channel is new.
   */
  public createChannel(channelId: string, channelInfo: any): void {
    let channel = this.channels.get(channelId);

    if (!channel) {
      channel = {
        subscribers: new Set(),
        channelInfo
      };
      this.channels.set(channelId, channel);
    } else {
      // Channel already exists - only set channelInfo if not already set
      if (channel.channelInfo === undefined) {
        channel.channelInfo = channelInfo;

        // Send channelInfo to all current subscribers
        const channelInfoMessage: IPubSubChannelInfo = {
          channelId,
          channelInfo,
          timestamp: Date.now()
        };

        channel.subscribers.forEach((subscriber: SubscriberInfo) => {
          const phone = this.phones.get(subscriber.interactiveId);
          if (phone) {
            phone.post("pubSubChannelInfo", channelInfoMessage);
          }
        });
      }
    }
  }

  /**
   * Subscribe an interactive to a channel.
   * If channelInfo already exists for this channel, immediately send it to the new subscriber.
   */
  public subscribe(interactiveId: string, channelId: string, subscriptionId: string): void {
    let channel = this.channels.get(channelId);

    if (!channel) {
      channel = {
        subscribers: new Set()
      };
      this.channels.set(channelId, channel);
    }

    channel.subscribers.add({ interactiveId, subscriptionId });

    // If channelInfo already exists for this channel, send it to the new subscriber
    if (channel.channelInfo !== undefined) {
      const channelInfoMessage: IPubSubChannelInfo = {
        channelId,
        channelInfo: channel.channelInfo,
        timestamp: Date.now()
      };

      const phone = this.phones.get(interactiveId);
      if (phone) {
        phone.post("pubSubChannelInfo", channelInfoMessage);
      }
    }
  }

  /**
   * Unsubscribe an interactive from a channel.
   */
  public unsubscribe(interactiveId: string, channelId: string, subscriptionId: string): void {
    const channel = this.channels.get(channelId);

    if (!channel) {
      return;
    }

    // Find and remove the subscriber
    channel.subscribers.forEach((subscriber: SubscriberInfo) => {
      if (subscriber.interactiveId === interactiveId && subscriber.subscriptionId === subscriptionId) {
        channel.subscribers.delete(subscriber);
      }
    });

    // Clean up empty channels
    if (channel.subscribers.size === 0) {
      this.channels.delete(channelId);
    }
  }

  /**
   * Publish a message to all subscribers on a channel.
   */
  public publish(publisherId: string, channelId: string, message: any): void {
    const channel = this.channels.get(channelId);

    if (!channel) {
      return;
    }

    channel.lastPublishTime = Date.now();

    const pubSubMessage: IPubSubMessage = {
      channelId,
      message,
      publisherId,
      timestamp: channel.lastPublishTime
    };

    channel.subscribers.forEach((subscriber: SubscriberInfo) => {
      const phone = this.phones.get(subscriber.interactiveId);
      if (phone) {
        phone.post("pubSubMessage", pubSubMessage);
      }
    });
  }
}
