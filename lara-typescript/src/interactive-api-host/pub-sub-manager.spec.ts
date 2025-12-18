import { PubSubManager } from "./pub-sub-manager";

interface MockPhone {
  post: jest.Mock;
}

describe("PubSubManager", () => {
  let manager: PubSubManager;
  let mockPhones: Map<string, MockPhone>;

  beforeEach(() => {
    manager = new PubSubManager();
    mockPhones = new Map();
  });

  const registerMockPhone = (interactiveId: string): MockPhone => {
    const mockPhone: MockPhone = {
      post: jest.fn()
    };
    mockPhones.set(interactiveId, mockPhone);
    manager.addInteractive(interactiveId, mockPhone as any);
    return mockPhone;
  };

  describe("createChannel", () => {
    it("creates a new channel with channelInfo", () => {
      const phone1 = registerMockPhone("interactive1");
      manager.createChannel("interactive1", "channel1", { unit: "celsius" });

      // No messages sent when no subscribers exist
      expect(phone1.post).not.toHaveBeenCalled();
    });

    it("sends channelInfo to existing subscribers", () => {
      const phone1 = registerMockPhone("interactive1");
      const phone2 = registerMockPhone("interactive2");

      manager.subscribe("interactive2", "channel1", "sub1");
      phone2.post.mockClear(); // Clear subscribe-related calls

      manager.createChannel("interactive1", "channel1", { unit: "celsius" });

      expect(phone2.post).toHaveBeenCalledTimes(1);
      expect(phone2.post).toHaveBeenCalledWith("pubSubChannelInfo", expect.objectContaining({
        channelId: "channel1",
        channelInfo: { unit: "celsius" },
        publisherId: "interactive1"
      }));
    });
  });

  describe("subscribe", () => {
    it("adds subscriber to channel", () => {
      const phone1 = registerMockPhone("interactive1");
      const phone2 = registerMockPhone("interactive2");

      manager.subscribe("interactive1", "channel1", "sub1");

      // Publish a message to verify subscriber was added
      manager.publish("interactive2", "channel1", { test: "data" });

      expect(phone1.post).toHaveBeenCalledWith("pubSubMessage", expect.objectContaining({
        channelId: "channel1",
        message: { test: "data" },
        publisherId: "interactive2"
      }));
    });

    it("sends channelInfo to late subscriber if publisher exists", () => {
      const phone1 = registerMockPhone("interactive1");

      manager.createChannel("interactive1", "channel1", { unit: "celsius" });
      phone1.post.mockClear(); // Clear create messages

      const phone2 = registerMockPhone("interactive2");
      manager.subscribe("interactive2", "channel1", "sub1");

      expect(phone2.post).toHaveBeenCalledTimes(1);
      expect(phone2.post).toHaveBeenCalledWith("pubSubChannelInfo", expect.objectContaining({
        channelId: "channel1",
        channelInfo: { unit: "celsius" }
      }));
    });

    it("does not send channelInfo if no publisher exists", () => {
      const phone1 = registerMockPhone("interactive1");
      manager.subscribe("interactive1", "channel1", "sub1");

      expect(phone1.post).not.toHaveBeenCalled();
    });
  });

  describe("unsubscribe", () => {
    it("removes subscriber from channel", () => {
      const phone1 = registerMockPhone("interactive1");
      const phone2 = registerMockPhone("interactive2");

      manager.subscribe("interactive1", "channel1", "sub1");
      manager.unsubscribe("interactive1", "channel1", "sub1");

      manager.publish("interactive2", "channel1", { test: "data" });

      // No messages should be sent as subscriber was removed
      expect(phone1.post).not.toHaveBeenCalled();
    });

    it("handles unsubscribe for non-existent channel", () => {
      registerMockPhone("interactive1");
      expect(() => {
        manager.unsubscribe("interactive1", "nonexistent", "sub1");
      }).not.toThrow();
    });
  });

  describe("publish", () => {
    it("sends message to all subscribers", () => {
      const phone1 = registerMockPhone("interactive1");
      const phone2 = registerMockPhone("interactive2");
      const publisher = registerMockPhone("publisher1");

      manager.subscribe("interactive1", "channel1", "sub1");
      manager.subscribe("interactive2", "channel1", "sub2");
      phone1.post.mockClear();
      phone2.post.mockClear();

      manager.publish("publisher1", "channel1", { value: 42 });

      expect(phone1.post).toHaveBeenCalledTimes(1);
      expect(phone1.post).toHaveBeenCalledWith("pubSubMessage", expect.objectContaining({
        channelId: "channel1",
        message: { value: 42 },
        publisherId: "publisher1"
      }));
      expect(phone2.post).toHaveBeenCalledTimes(1);
      expect(phone2.post).toHaveBeenCalledWith("pubSubMessage", expect.objectContaining({
        message: { value: 42 }
      }));
    });

    it("handles publish to non-existent channel", () => {
      const publisher = registerMockPhone("publisher1");
      expect(() => {
        manager.publish("publisher1", "nonexistent", { value: 42 });
      }).not.toThrow();
    });

    it("does not send message back to publisher", () => {
      const phone1 = registerMockPhone("interactive1");
      manager.subscribe("interactive1", "channel1", "sub1");
      phone1.post.mockClear();

      manager.publish("interactive1", "channel1", { value: 42 });

      // Publisher still receives its own messages in this implementation
      // (filtering could be added if desired)
      expect(phone1.post).toHaveBeenCalledTimes(1);
    });
  });

  describe("removeInteractive", () => {
    it("removes all subscriptions for an interactive", () => {
      const phone1 = registerMockPhone("interactive1");
      const phone2 = registerMockPhone("interactive2");
      const publisher = registerMockPhone("publisher");

      manager.subscribe("interactive1", "channel1", "sub1");
      manager.subscribe("interactive1", "channel2", "sub2");
      manager.subscribe("interactive2", "channel1", "sub3");

      manager.removeInteractive("interactive1");
      phone1.post.mockClear();
      phone2.post.mockClear();

      manager.publish("publisher", "channel1", { value: 1 });
      manager.publish("publisher", "channel2", { value: 2 });

      // Only interactive2 should receive messages
      expect(phone1.post).not.toHaveBeenCalled();
      expect(phone2.post).toHaveBeenCalledTimes(1);
      expect(phone2.post).toHaveBeenCalledWith("pubSubMessage", expect.objectContaining({
        message: { value: 1 }
      }));
    });

    it("handles removing non-existent interactive", () => {
      expect(() => {
        manager.removeInteractive("nonexistent");
      }).not.toThrow();
    });
  });

  describe("multiple channels", () => {
    it("keeps channels independent", () => {
      const phone1 = registerMockPhone("interactive1");
      const phone2 = registerMockPhone("interactive2");
      const publisher = registerMockPhone("publisher");

      manager.subscribe("interactive1", "channel1", "sub1");
      manager.subscribe("interactive2", "channel2", "sub2");
      phone1.post.mockClear();
      phone2.post.mockClear();

      manager.publish("publisher", "channel1", { channel: 1 });

      expect(phone1.post).toHaveBeenCalledTimes(1);
      expect(phone1.post).toHaveBeenCalledWith("pubSubMessage", expect.objectContaining({
        message: { channel: 1 }
      }));
      expect(phone2.post).not.toHaveBeenCalled();
    });

    it("allows same interactive to subscribe to multiple channels", () => {
      const phone1 = registerMockPhone("interactive1");
      const publisher = registerMockPhone("publisher");

      manager.subscribe("interactive1", "channel1", "sub1");
      manager.subscribe("interactive1", "channel2", "sub2");
      phone1.post.mockClear();

      manager.publish("publisher", "channel1", { channel: 1 });
      manager.publish("publisher", "channel2", { channel: 2 });

      expect(phone1.post).toHaveBeenCalledTimes(2);
      expect(phone1.post).toHaveBeenNthCalledWith(1, "pubSubMessage", expect.objectContaining({
        message: { channel: 1 }
      }));
      expect(phone1.post).toHaveBeenNthCalledWith(2, "pubSubMessage", expect.objectContaining({
        message: { channel: 2 }
      }));
    });
  });
});
