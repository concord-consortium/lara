export interface IRubricCriteriaGroup {
  label: string;
  labelForStudent: string;
  criteria: IRubricCriterion[];
}

export interface IRubricCriterion {
  id: string;
  description: string;
  descriptionForStudent: string;
  nonApplicableRatings: string[];
  ratingDescriptions: Record<string, string>;
  ratingDescriptionsForStudent: Record<string, string>;
  iconUrl: string;
}

export interface IRubricRating {
  id: string;
  label: string;
  score: number;
}

export interface IRubricV110 {
  id: string;
  version: "1.0.0" | "1.1.0";
  versionNumber: string;
  updatedMsUTC: number;
  originUrl: string;
  showRatingDescriptions: boolean;
  hideRubricFromStudentsInStudentReport: boolean;
  criteriaLabel: string;
  criteriaLabelForStudent: string;
  feedbackLabelForStudent: string;
  criteria: IRubricCriterion[];
  ratings: IRubricRating[];
}

export type IRubric = Omit<IRubricV110, "version" | "criteria"> & {
  version: "1.2.0";
  criteriaGroups: IRubricCriteriaGroup[];
};
