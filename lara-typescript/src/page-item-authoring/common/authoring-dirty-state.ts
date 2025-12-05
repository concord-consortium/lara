/**
 * Manages dirty state for library interactives in authoring mode.
 * This prevents accidental loss of data when closing or saving the authoring dialog
 * while an interactive has unsaved changes.
 */

// Track dirty state for each interactive by interactive item ID
const interactiveDirtyStates: Map<string, { dirty: boolean; message?: string }> = new Map();

export const setInteractiveDirtyState = (
  interactiveItemId: string,
  state: { dirty: boolean; message?: string }
): void => {
  if (state.dirty) {
    interactiveDirtyStates.set(interactiveItemId, state);
  } else {
    interactiveDirtyStates.delete(interactiveItemId);
  }
};

export const hasUnsavedInteractiveChanges = (): boolean => {
  return interactiveDirtyStates.size > 0;
};

export const getDirtyInteractiveMessage = (): string => {
  const states = Array.from(interactiveDirtyStates.values());
  for (const state of states) {
    if (state.message) {
      return state.message;
    }
  }
  return "An interactive has unsaved changes. Are you sure you want to close?";
};

export const clearInteractiveDirtyState = (interactiveItemId: string): void => {
  interactiveDirtyStates.delete(interactiveItemId);
};

export const clearAllDirtyStates = (): void => {
  interactiveDirtyStates.clear();
};
