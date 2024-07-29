import { createContext, Dispatch, SetStateAction, useContext, useEffect, useState } from "react";
import { Updater, useImmer } from "use-immer";
import { IRubric } from "./types";

export interface IRubricContext {
  rubric: IRubric;
  setRubric: Updater<IRubric>;
  loadStatus: "loading" | "loaded" | "error";
}

export const useRubricValue = () => {
  const [rubric, setRubric] = useImmer<IRubric>({} as IRubric);
  const [loadStatus, setLoadStatus] = useState<IRubricContext["loadStatus"]>("loading");

  useEffect(() => {
    // TBD: load rubric and run migrations

    setRubric({
      id: "",
      version: "1.2.0",
      versionNumber: "",
      updatedMsUTC: 0,
      originUrl: "",
      referenceURL: "",
      showRatingDescriptions: false,
      scoreUsingPoints: false,
      hideRubricFromStudentsInStudentReport: false,
      criteriaLabel: "",
      criteriaLabelForStudent: "",
      feedbackLabelForStudent: "",
      criteriaGroups: [],
      ratings: [],
    });

    setLoadStatus("loaded");
  }, []);

  return {
    rubric,
    setRubric,
    loadStatus
  };
};

export const RubricContext = createContext<IRubricContext>({} as IRubricContext);

export const useRubric = () => useContext(RubricContext);
