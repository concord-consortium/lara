export interface IRubricCriterion {
  id: string;
  description: string;
  nonApplicableRatings: string[];
  ratingDescriptions: Record<string, string>;
}

export interface IRubricRating {
  id: string;
  label: string;
  score: number;
}

export interface IRubric {
  id: string;
  version: string;
  versionNumber: string;
  updatedMsUTC: number;
  originUrl: string;
  referenceURL: string;
  showRatingDescriptions: boolean;
  scoreUsingPoints: boolean;
  hideRubricFromStudentsInStudentReport: boolean;
  criteriaLabel: string;
  criteriaLabelForStudent: string;
  feedbackLabelForStudent: string;
  criteria: IRubricCriterion[];
  ratings: IRubricRating[];
}
