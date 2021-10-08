
export const flatten = <t> (items: t[][]): t[] => {
  return [].concat.apply([], items);
};

export const collect = <t> (count: number, fn: () => t): t[] => {
  const result: t[] = [];
  for (let i = 0; i < count; i++) {
    result.push(fn());
  }
  return result;
};
