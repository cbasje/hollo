import type { SeriesId, SessionType } from "../../hunter/schema";

export const getSessionTitle = (
  series: SeriesId | null,
  type: SessionType | null,
  number: number,
) => {
  const feederTitles: Record<SessionType, string> = {
    R: "Feature Race",
    S: "Sprint Race",
    Q: "Qualifying",
    SQ: "",
    FP: "Practice",
    T: "Testing",
    TBC: "TBC",
    W: "Warmup",
  };
  const defaultTitles: Record<SessionType, string> = {
    R: "Race",
    S: "Sprint",
    Q: "Qualifying",
    SQ: "Sprint Qualifying",
    FP: "Practice",
    T: "Testing",
    TBC: "TBC",
    W: "Warmup",
  };

  if (!type) {
    return "-";
  } else if (series === "F2" || series === "F3") {
    return `${feederTitles[type]} ${number > 0 ? number : ""}`;
  } else {
    return `${defaultTitles[type]} ${number > 0 ? number : ""}`;
  }
};
