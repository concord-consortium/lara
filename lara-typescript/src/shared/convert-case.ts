export const camelToSnakeCase = (key: string) => {
  return key.replace(/[A-Z]/g, (l: string) => `_${l.toLowerCase()}`);
};

export const snakeToCamelCase = (key: string) => {
  return key.replace(/_./g, (l: string) => l.substring(1).toUpperCase());
};
