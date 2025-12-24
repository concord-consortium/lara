import { mockIFramePhone, MockPhone } from "../interactive-api-lara-host/mock-iframe-phone";
import { PubSubChannel } from "./pubsub";
import { Client } from "./client";
import * as iframePhone from "iframe-phone";

jest.mock("iframe-phone", () => {
  return mockIFramePhone();
});

const inIframe = jest.fn();
jest.mock("./in-frame", () => ({
  inIframe: () => inIframe()
}));

const mockedPhone = iframePhone.getIFrameEndpoint() as unknown as MockPhone;

describe("PubSubChannel", () => {
  let client: Client;

  beforeEach(() => {
    inIframe.mockImplementation(() => true);
    mockedPhone.reset();
    client = new Client();
  });

  afterEach(() => {
    mockedPhone.reset();
  });

  describe("constructor", () => {
    it("creates a channel with channelId", () => {
      const channel = new PubSubChannel(client, "test-channel");
      expect(channel.getChannelId()).toBe("test-channel");
    });

    it("creates a channel with channelId and channelInfo", () => {
      const channelInfo = { unit: "celsius" };
      const channel = new PubSubChannel(client, "test-channel", channelInfo);
      expect(channel.getChannelId()).toBe("test-channel");
      expect(channel.getChannelInfo()).toEqual(channelInfo);
    });
  });

  describe("publish", () => {
    it("sends createChannel message when channelInfo is provided and not yet created", () => {
      const channelInfo = { unit: "celsius" };
      const channel = new PubSubChannel(client, "test-channel", channelInfo);

      channel.publish({ value: 22.5 });

      const messages = mockedPhone.messages;
      expect(messages.length).toBe(2);
      expect(messages[0].type).toBe("createChannel");
      expect(messages[0].content.channelId).toBe("test-channel");
      expect(messages[0].content.channelInfo).toEqual(channelInfo);
      expect(messages[1].type).toBe("publish");
      expect(messages[1].content.message).toEqual({ value: 22.5 });
    });

    it("does not send createChannel on subsequent publishes", () => {
      const channelInfo = { unit: "celsius" };
      const channel = new PubSubChannel(client, "test-channel", channelInfo);

      channel.publish({ value: 22.5 });
      mockedPhone.reset(); // Clear messages
      channel.publish({ value: 23.0 });

      const messages = mockedPhone.messages;
      expect(messages.length).toBe(1);
      expect(messages[0].type).toBe("publish");
      expect(messages[0].content.message).toEqual({ value: 23.0 });
    });

    it("sends only publish message when no channelInfo provided", () => {
      const channel = new PubSubChannel(client, "test-channel");
      mockedPhone.reset(); // Clear createChannel message from constructor

      channel.publish({ value: 22.5 });

      const messages = mockedPhone.messages;
      expect(messages.length).toBe(1);
      expect(messages[0].type).toBe("publish");
      expect(messages[0].content.channelId).toBe("test-channel");
      expect(messages[0].content.message).toEqual({ value: 22.5 });
    });
  });

  describe("subscribe", () => {
    it("sends subscribe message to host", () => {
      const channel = new PubSubChannel(client, "test-channel");
      mockedPhone.reset(); // Clear createChannel message from constructor
      const handler = jest.fn();

      channel.subscribe(handler);

      const messages = mockedPhone.messages;
      expect(messages.length).toBe(1);
      expect(messages[0].type).toBe("subscribe");
      expect(messages[0].content.channelId).toBe("test-channel");
      expect(messages[0].content.subscriptionId).toBeDefined();
    });

    it("returns an unsubscribe function", () => {
      const channel = new PubSubChannel(client, "test-channel");
      const handler = jest.fn();

      const unsubscribe = channel.subscribe(handler);

      expect(typeof unsubscribe).toBe("function");
    });

    it("unsubscribe function sends unsubscribe message", () => {
      const channel = new PubSubChannel(client, "test-channel");
      const handler = jest.fn();

      const unsubscribe = channel.subscribe(handler);
      mockedPhone.reset(); // Clear subscribe message
      unsubscribe();

      const messages = mockedPhone.messages;
      expect(messages.length).toBe(1);
      expect(messages[0].type).toBe("unsubscribe");
      expect(messages[0].content.channelId).toBe("test-channel");
    });
  });

  describe("setChannelInfo", () => {
    it("sends createChannel message with new channelInfo", () => {
      const channel = new PubSubChannel(client, "test-channel");
      mockedPhone.reset(); // Clear initial createChannel message from constructor

      channel.setChannelInfo({ unit: "fahrenheit" });

      const messages = mockedPhone.messages;
      expect(messages.length).toBe(1);
      expect(messages[0].type).toBe("createChannel");
      expect(messages[0].content.channelInfo).toEqual({ unit: "fahrenheit" });
    });

    it("updates the channelInfo", () => {
      const channel = new PubSubChannel(client, "test-channel", { unit: "celsius" });

      channel.setChannelInfo({ unit: "fahrenheit" });

      expect(channel.getChannelInfo()).toEqual({ unit: "fahrenheit" });
    });
  });

  describe("dispose", () => {
    it("unsubscribes all subscriptions", () => {
      const channel = new PubSubChannel(client, "test-channel");

      channel.subscribe(jest.fn());
      channel.subscribe(jest.fn());

      mockedPhone.reset(); // Clear subscribe messages
      channel.dispose();

      const messages = mockedPhone.messages;
      expect(messages.length).toBe(2);
      expect(messages[0].type).toBe("unsubscribe");
      expect(messages[1].type).toBe("unsubscribe");
    });
  });
});
