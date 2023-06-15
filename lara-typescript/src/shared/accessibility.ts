export const pxForFontSize = (fontSize: string) => {
  if (fontSize === "large") {
    return 22;
  }
  return 16;
};

export const getFamilyForFontType = (fontType: string) => {
  const baseFontFamily = "'Lato', arial, helvetica, sans-serif;";
  if (fontType === "notebook") {
    return `'Andika', ${baseFontFamily}`;
  }
  return baseFontFamily;
};
