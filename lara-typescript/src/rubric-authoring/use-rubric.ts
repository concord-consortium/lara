import { createContext, Dispatch, SetStateAction, useContext, useEffect, useState } from "react";
import { Updater, useImmer } from "use-immer";
import { IRubric } from "./types";

export interface IRubricContext {
  rubric: IRubric;
  setRubric: Updater<IRubric>;
  loadStatus: "loading" | "loaded" | "error";
  saveStatus: "unsaved" | "saving" | "saved" | "error";
  isDirty: boolean;
  saveRubric: () => void;
}

const migrate = (rubric: IRubric ) => {
  // right now there are no explicit version migrations BUT iconPhrase was added without a version bump
  // so ensure that it is an empty string if it is undefined
  rubric.criteriaGroups.forEach(criteriaGroup => {
    criteriaGroup.criteria.forEach(criteria => {
      criteria.iconPhrase = criteria.iconPhrase ?? "";
    });
  });
  return rubric;
};

export const useRubricValue = (authoredContentUrl: string): IRubricContext => {
  const [rubric, _setRubric] = useImmer<IRubric>({} as IRubric);
  const [loadStatus, setLoadStatus] = useState<IRubricContext["loadStatus"]>("loading");
  const [saveStatus, setSaveStatus] = useState<IRubricContext["saveStatus"]>("unsaved");
  const [isDirty, setIsDirty] = useState(false);

  const setRubric: Updater<IRubric> = (arg) => {
    setIsDirty(true);
    setSaveStatus("unsaved");
    _setRubric(arg);
  };

  useEffect(() => {
    const loadAuthoredContent = async () => {
      try {
        const {url} = await (await fetch(authoredContentUrl)).json();
        if (url) {
          const unmigratedRubric = await (await fetch(url)).json();
          const migratedRubric = migrate(unmigratedRubric);
          _setRubric(migratedRubric);
        } else {
          _setRubric({
            id: "",
            version: "1.2.0",
            versionNumber: "",
            updatedMsUTC: 0,
            originUrl: "",
            showRatingDescriptions: false,
            hideRubricFromStudentsInStudentReport: false,
            criteriaLabel: "",
            criteriaLabelForStudent: "",
            feedbackLabelForStudent: "",
            criteriaGroups: [],
            ratings: [],
          });
        }
        setLoadStatus("loaded");
      } catch (e) {
        alert(e.toString());
      }
    };

    // tslint:disable-next-line:no-console
    loadAuthoredContent().catch(console.error);
  }, []);

  const saveRubric = () => {
    const saveAuthoredContent = async () => {
      try {
        setSaveStatus("saving");
        const resp = await fetch(authoredContentUrl, {
          method: "PUT",
          credentials: "include",
          body: JSON.stringify(rubric)
        });
        if (resp.status === 200) {
          setSaveStatus("saved");
          setIsDirty(false);
        } else {
          setSaveStatus("error");
          alert("Unable to save rubric!");
        }
      } catch (e) {
        alert(e.toString());
      }
    };

    // tslint:disable-next-line:no-console
    saveAuthoredContent().catch(console.error);
  };

  return {
    rubric,
    setRubric,
    loadStatus,
    saveStatus,
    isDirty,
    saveRubric
  };
};

export const RubricContext = createContext<IRubricContext>({} as IRubricContext);

export const useRubric = () => useContext(RubricContext);
