import { useEffect, useRef, useState } from "react";

interface NavigationGuardOptions {
  isDirty: boolean;
  onBeforeNavigation?: () => Promise<boolean>; // Return true to allow navigation
}

/**
 * Hook to guard against navigation when there are unsaved changes.
 */
export const useNavigationGuard = (options: NavigationGuardOptions) => {
  const [pendingNavigation, setPendingNavigation] = useState<(() => void) | null>(null);
  const optionsRef = useRef(options);

  useEffect(() => {
    optionsRef.current = options;
  }, [options]);

  useEffect(() => {
    const handleBeforeUnload = (e: BeforeUnloadEvent) => {
      if (optionsRef.current.isDirty) {
        e.preventDefault();
        e.returnValue = ""; // Some browsers require this to show the prompt
      }
    };

    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => window.removeEventListener("beforeunload", handleBeforeUnload);
  }, []);

  /**
   * Check if navigation should be allowed based on dirty state.
   * If dirty, calls the onBeforeNavigation callback if provided.
   */
  const checkNavigation = async (): Promise<boolean> => {
    if (!optionsRef.current.isDirty) return true;

    if (optionsRef.current.onBeforeNavigation) {
      const result = await optionsRef.current.onBeforeNavigation();
      return result;
    }

    // If no custom handler, default to simply blocking navigation.
    return false;
  };

  /**
   * Programmatically attempt navigation.
   * If there are unsaved changes, this will trigger the navigation guard flow.
   */
  const attemptNavigation = async (navigationFn: () => void): Promise<boolean> => {
    const canNavigate = await checkNavigation();
    if (canNavigate) {
      navigationFn();
      return true;
    } else {
      setPendingNavigation(() => navigationFn);
      return false;
    }
  };

  const confirmNavigation = () => {
    pendingNavigation?.();
    setPendingNavigation(null);
  };

  const cancelNavigation = () => setPendingNavigation(null);

  const isNavigationBlocked = pendingNavigation !== null;

  return {
    attemptNavigation,
    cancelNavigation,
    checkNavigation,
    confirmNavigation,
    isNavigationBlocked
  };
};
