// returns a type-safe form id/name generator
export const RailsFormField = <T>(name: string) => {
  return (field: keyof T) => ({
    id: `${name}_${field}`,
    name: `${name}[${field}]`,
  });
};
