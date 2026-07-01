import {
  IFocusEnterMessage,
  IFocusExitMessage,
  FocusEnterMode,
  FocusExitMode,
  ISupportedFeatures
} from "./types";

// These assignments fail to COMPILE (ts-jest) if the types are missing or wrong,
// which is this task's red/green signal — there is no runtime behavior to test.
describe("focus-protocol shared types", () => {
  it("defines focusEnter / focusExit message payloads and the focusProtocol feature", () => {
    const enterModes: FocusEnterMode[] = ["forward", "reverse", "restore"];
    const exitModes: FocusExitMode[] = ["forward", "reverse", "escape"];
    const enter: IFocusEnterMessage = { mode: "forward" };
    const exit: IFocusExitMessage = { mode: "escape" };
    const features: ISupportedFeatures = { focusProtocol: true };

    expect(enterModes).toContain(enter.mode);
    expect(exitModes).toContain(exit.mode);
    expect(features.focusProtocol).toBe(true);
  });
});
