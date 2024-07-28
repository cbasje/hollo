import { and, eq, gte, lte, sql } from "drizzle-orm";
import db from "..";
import { circuits, rounds, sessions } from "../../hunter/schema";
import { getWeekendDatesFromOffset } from "../../utils/date";

export const getOne = async (id: string) => {
  const [result] = await db
    .select({
      id: sessions.id,
      type: sessions.type,
      number: sessions.number,
      start: sessions.start,
      end: sessions.end,
      year: sql<number>`DATE_PART('year', ${rounds.start})`,
      weekNumber: sql<number>`DATE_PART('week', ${rounds.start})`,
      weekendOffset: sql<number>`DATE_PART('week', ${rounds.start}) - DATE_PART('week', NOW())`,
      series: rounds.series,
      roundTitle: rounds.title,
      link: rounds.link,
      country: circuits.country,
      locality: circuits.locality,
      circuitTitle: circuits.title,
      lat: circuits.lat,
      lon: circuits.lon,
    })
    .from(sessions)
    .leftJoin(rounds, eq(sessions.roundId, rounds.id))
    .leftJoin(circuits, eq(circuits.id, rounds.circuitId))
    .where(eq(sessions.id, id))
    .limit(1);
  return result;
};

export const getWeekend = async (weekendOffset = 0) => {
  const [start, end] = getWeekendDatesFromOffset(weekendOffset);

  const result = await db
    .select({
      id: sessions.id,
      type: sessions.type,
      number: sessions.number,
      start: sessions.start,
      end: sessions.end,
      year: sql<number>`DATE_PART('year', ${rounds.start})`,
      weekNumber: sql<number>`DATE_PART('week', ${rounds.start})`,
      weekendOffset: sql<number>`DATE_PART('week', ${rounds.start}) - DATE_PART('week', NOW())`,
      series: rounds.series,
      roundTitle: rounds.title,
      link: rounds.link,
      country: circuits.country,
      locality: circuits.locality,
      circuitTitle: circuits.title,
      lat: circuits.lat,
      lon: circuits.lon,
    })
    .from(sessions)
    .leftJoin(rounds, eq(sessions.roundId, rounds.id))
    .leftJoin(circuits, eq(circuits.id, rounds.circuitId))
    .where(
      and(gte(rounds.start, start.toString()), lte(rounds.end, end.toString())),
    );
  return result;
};
