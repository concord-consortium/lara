import * as React from "react";
import { fireEvent, render, screen } from "@testing-library/react";
import { ItemEditDialog } from "./item-edit-dialog";
import { UserInterfaceContext } from "../containers/user-interface-provider";
import { ISectionItem } from "../api/api-types";
import { camelToSnakeCaseKeys } from "../../shared/convert-keys";
import { QuestionGatingOptions } from "../../page-item-authoring/common/components/question-gating-options";

const mockUpdatePageItem = jest.fn();
const savedItem: ISectionItem = {
  id: "1",
  column: "primary",
  position: 1,
  type: "MwInteractive",
  data: {
    name: "Gate",
    questionGating: "disable_following_on_page",
    questionGatingLockedText: "Saved locked text",
    questionGatingUnlockedText: "Saved unlocked text"
  }
} as ISectionItem;

jest.mock("../hooks/use-api-provider", () => ({
  usePageAPI: () => ({
    getItems: () => [savedItem],
    updatePageItem: mockUpdatePageItem,
    getLibraryInteractives: { data: undefined }
  })
}));

jest.mock("../../page-item-authoring/mw-interactives", () => ({
  MWInteractiveAuthoring: ({ interactive }: any) =>
    <QuestionGatingOptions
      questionGating={interactive.question_gating}
      lockedText={interactive.question_gating_locked_text}
      unlockedText={interactive.question_gating_unlocked_text}
    />
}));

jest.mock("./mw-interactive-preview", () => ({
  MWInteractivePreview: () => null
}));

const renderDialog = () => render(
  <UserInterfaceContext.Provider value={{
    userInterface: { editingItemId: "1", wrappedItemId: false },
    actions: { setEditingItemId: jest.fn(), setWrappedItemId: jest.fn() }
  } as any}>
    <ItemEditDialog />
  </UserInterfaceContext.Provider>
);

const sentData = () => {
  expect(mockUpdatePageItem).toHaveBeenCalledTimes(1);
  return camelToSnakeCaseKeys(mockUpdatePageItem.mock.calls[0][0].data);
};

describe("ItemEditDialog question gating", () => {
  beforeEach(() => mockUpdatePageItem.mockClear());

  it("keeps the saved banner texts when the setting is changed to No questions", () => {
    renderDialog();
    const select = screen.getByLabelText("Locked until this interactive unlocks them");
    fireEvent.change(select, { target: { value: "none" } });
    expect(screen.queryByLabelText("Locked banner text")).toBeNull();

    fireEvent.click(screen.getByRole("button", { name: "Save" }));

    expect(sentData()).toMatchObject({
      question_gating: "none",
      question_gating_locked_text: "Saved locked text",
      question_gating_unlocked_text: "Saved unlocked text"
    });
  });

  it("sends edited banner texts while a locking value is selected", () => {
    renderDialog();
    fireEvent.change(screen.getByLabelText("Locked banner text"), { target: { value: "New locked text" } });

    fireEvent.click(screen.getByRole("button", { name: "Save" }));

    expect(sentData()).toMatchObject({
      question_gating: "disable_following_on_page",
      question_gating_locked_text: "New locked text",
      question_gating_unlocked_text: "Saved unlocked text"
    });
  });
});
