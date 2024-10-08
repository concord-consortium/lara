export interface IProject {
  about?: string;
  collaborators?: string;
  collaboratorsImageUrl?: string;
  contactEmail?: string;
  copyright?: string;
  copyrightImageUrl?: string;
  footer?: string;
  fundersImageUrl?: string;
  id: number | undefined;
  logoAp?: string;
  logoLara?: string;
  projectKey: string | undefined;
  title: string;
  url?: string;
}
export interface IProjectAdmin {
  id: number;
  email: string;
}
