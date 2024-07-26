import { createContext, Dispatch, SetStateAction, useContext, useEffect, useState } from "react";
import { IRubric } from "./types";

export interface IRubricContext {
  rubric: IRubric;
  setRubric: Dispatch<SetStateAction<IRubric>>;
  loadStatus: "loading" | "loaded" | "error";
}

export const useRubricValue = () => {
  const [rubric, setRubric] = useState<IRubric>({} as IRubric);
  const [loadStatus, setLoadStatus] = useState<IRubricContext["loadStatus"]>("loading");

  useEffect(() => {
    // TBD: load rubric

    setRubric({
      id: "",
      version: "",
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
      criteria: [],
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
