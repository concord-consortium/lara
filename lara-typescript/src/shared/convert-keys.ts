export const camelToSnakeCaseKeys = (object: any) => {
  const translatedObject: any = {};
  Object.keys(object).forEach((key: string) => {
    const newKey = key.replace(/[A-Z]/g, (l: string) => `_${l.toLowerCase()}`);
    translatedObject[newKey] = object[key];
  });
  return translatedObject;
};

export const snakeToCamelCaseKeys = (object: any) => {
  const translatedObject: any = {};
  Object.keys(object).forEach((key: string) => {
    const newKey = key.replace(/_./g, (l: string) => l.substring(1).toUpperCase());
    translatedObject[newKey] = object[key];
  });
  return translatedObject;
};
