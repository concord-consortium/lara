export interface IPortalClaims {
  class_hash: string;
  offering_id: number;
  platform_id: string;
  platform_user_id: number;
  user_id: string;
  user_type: "learner" | "teacher";
}

export interface IJwtClaims {
  alg: string;
  aud: string;
  class_info_url: string;
  domain: string;
  domain_uid: number;
  exp: number;
  externalId: number;
  iat: number;
  iss: string;
  logging: boolean;
  returnUrl: string;
  sub: string;
  uid: string;
  claims: IPortalClaims;
}

export interface IJwtResponse {
  token: string;
  claims: IJwtClaims;
}
