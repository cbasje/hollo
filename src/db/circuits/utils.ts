import type { Circuit, SeriesId } from "../../hunter/schema";

const regionNames = new Intl.DisplayNames(undefined, { type: "region" });

export const getCircuitTitle = (
  series: SeriesId | null,
  circuitTitle: string | null,
  countryCode: string | null,
  locality: Circuit["locality"],
) => {
  if (series === "INDY") {
    return locality ? locality : circuitTitle;
  }
  if (countryCode) {
    return regionNames.of(countryCode);
  }
  return undefined;
};
