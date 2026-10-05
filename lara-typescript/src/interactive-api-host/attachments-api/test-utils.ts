export const base64url = (value: string) =>
  Buffer.from(value).toString("base64").replace(/=+$/, "").replace(/\+/g, "-").replace(/\//g, "_");

export const makeJwt = (claims: Record<string, unknown>) =>
  `header.${base64url(JSON.stringify(claims))}.signature`;
