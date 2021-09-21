export const absorbClick = () => {
  return (e: React.MouseEvent<HTMLElement> | MouseEvent): void => {
    e.preventDefault();
    e.stopPropagation();
  };
};

export const absorbClickThen = (next: () => void) => {
  return (e: React.MouseEvent<HTMLElement> | MouseEvent): void => {
    e.preventDefault();
    e.stopPropagation();
    next();
  };
};
