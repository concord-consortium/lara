import { ManagedState } from "./managed-state";

describe("ManagedState", () => {
  it("emits messages when one of its properties gets updated", () => {
    const mState = new ManagedState();

    const initInteractive = jest.fn();
    mState.on("initInteractive", initInteractive);
    mState.initMessage = {initMessage: true};
    expect(initInteractive).toHaveBeenCalledWith({initMessage: true});
    expect(initInteractive).toHaveBeenCalledTimes(1);
    mState.off("initInteractive", initInteractive);
    mState.initMessage = {initMessage: "new value"};
    expect(initInteractive).toHaveBeenCalledTimes(1);

    const intStateUpdated = jest.fn();
    mState.on("interactiveStateUpdated", intStateUpdated);
    mState.interactiveState = {intState: true};
    expect(intStateUpdated).toHaveBeenCalledWith({intState: true});
    expect(intStateUpdated).toHaveBeenCalledTimes(1);
    mState.off("interactiveStateUpdated", intStateUpdated);
    mState.interactiveState = {intState: "new value"};
    expect(intStateUpdated).toHaveBeenCalledTimes(1);

    const authoredStateUpdated = jest.fn();
    mState.on("authoredStateUpdated", authoredStateUpdated);
    mState.authoredState = {authState: true};
    expect(authoredStateUpdated).toHaveBeenCalledWith({authState: true});
    expect(authoredStateUpdated).toHaveBeenCalledTimes(1);
    mState.off("authoredStateUpdated", authoredStateUpdated);
    mState.authoredState = {authState: "new value"};
    expect(authoredStateUpdated).toHaveBeenCalledTimes(1);

    const globalIntStateUpdated = jest.fn();
    mState.on("globalInteractiveStateUpdated", globalIntStateUpdated);
    mState.globalInteractiveState = {globalInteractiveState: true};
    expect(globalIntStateUpdated).toHaveBeenCalledWith({globalInteractiveState: true});
    expect(globalIntStateUpdated).toHaveBeenCalledTimes(1);
    mState.off("globalInteractiveStateUpdated", globalIntStateUpdated);
    mState.globalInteractiveState = {globalInteractiveState: "new value"};
    expect(globalIntStateUpdated).toHaveBeenCalledTimes(1);
  });

  it("freezes state objects", () => {
    const mState = new ManagedState();
    const props = ["initMessage", "interactiveState", "authoredState", "globalInteractiveState"];
    type State = "initMessage" | "interactiveState" | "authoredState" | "globalInteractiveState";

    props.forEach((prop: State) => {
      mState[prop] = {foo: 1, bar: 2};
      expect(() => {
        mState[prop].foo = "a new value";
      }).toThrowError();
      expect(() => {
        const state = mState[prop];
        state.foo = "a new value";
      }).toThrowError();
      expect(mState[prop]).toEqual({foo: 1, bar: 2});
    });
  });
});
