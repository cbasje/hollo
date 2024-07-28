import {
  getLocalTimeZone,
  startOfWeek,
  today,
  type CalendarDate,
} from "@internationalized/date";

const minute = 60 * 1000;
const hour = 60 * minute;
const day = 24 * hour;
const week = 7 * day;

export const isValidDate = (input: Date | string | null | undefined) => {
  const date = typeof input === "string" ? new Date(input) : input;
  if (date === undefined || date === null || Number.isNaN(date.valueOf()))
    return false;
  return true;
};

export const formatTrackTime = (timeZone: string, start: Date, end?: Date) => {
  const trackTimeFormat = new Intl.DateTimeFormat(undefined, {
    weekday: "short",
    hour: "numeric",
    minute: "numeric",
    timeZone,
  });

  if (end !== undefined) {
    return trackTimeFormat.formatRange(start, end);
  }

  return trackTimeFormat.format(start);
};

export const formatYourTime = (start: Date, end?: Date) => {
  const yourTimeFormat = new Intl.DateTimeFormat(undefined, {
    weekday: "short",
    hour: "numeric",
    minute: "numeric",
  });

  if (end !== undefined) {
    return yourTimeFormat.formatRange(start, end);
  }

  return yourTimeFormat.format(start);
};

export const formatRelTime = (date: Date, now: number) => {
  const rel = date.valueOf() - now;
  const relTimeFormat = new Intl.RelativeTimeFormat(undefined, {
    style: "long",
    numeric: "auto",
  });

  if (Math.abs(rel) > week) {
    return relTimeFormat.format(Math.floor(rel / week), "week");
  }
  if (Math.abs(rel) > day) {
    return relTimeFormat.format(Math.floor(rel / day), "day");
  }
  if (Math.abs(rel) > hour) {
    return relTimeFormat.format(Math.floor(rel / hour), "hour");
  }
  if (Math.abs(rel) > minute) {
    return relTimeFormat.format(Math.floor(rel / minute), "minute");
  }
};

export const formatRelWeekend = (weekend: number | string) => {
  const formatter = new Intl.RelativeTimeFormat(undefined, {
    numeric: "auto",
  });
  return formatter.format(
    typeof weekend === "string" ? Number.parseInt(weekend) : weekend,
    "week",
  );
};
export const formatRangeWeekend = (weekendOffset: number | string) => {
  const weekendOffsetNumber =
    typeof weekendOffset === "string"
      ? Number.parseInt(weekendOffset)
      : weekendOffset;
  const [start, end] = getWeekendDatesFromOffset(weekendOffsetNumber);

  const tz = getLocalTimeZone();

  const formatter = new Intl.DateTimeFormat(undefined, {
    dateStyle: "medium",
  });
  return formatter.formatRange(start.toDate(tz), end.toDate(tz));
};

export const getWeekendDatesFromOffset = (
  startOffset = 0,
  endOffset?: number,
): [CalendarDate, CalendarDate] => {
  const weekStart = startOfWeek(today(getLocalTimeZone()), "en-GB"); // Start on Monday

  return [
    weekStart.add({ weeks: startOffset }),
    weekStart.add({ weeks: (endOffset ?? startOffset) + 1 }),
  ];
};

export const getWeekendOffsetFromDates = (
  start: Date | null,
  end?: Date | null,
) => {
  if (!start) return 0;

  let millis: number;
  if (end) {
    millis = (start.valueOf() + end.valueOf()) / 2 - Date.now();
  } else {
    millis = start.valueOf() - Date.now();
  }

  return Math.round(millis / (7 * 24 * 60 * 60 * 1000));
};
