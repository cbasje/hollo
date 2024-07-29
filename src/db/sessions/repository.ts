import { and, eq, gte, lte, notInArray, sql } from "drizzle-orm";
import { concat } from "drizzle-orm/pg-core/expressions";
import db from "..";
import {
  circuits,
  rounds,
  sessions,
  type SessionType,
} from "../../hunter/schema";
import { getWeekendDatesFromOffset } from "../../utils/date";

export const getOne = async (id: string) => {
  const [result] = await db
    .select({
      id: sessions.id,
      type: sessions.type,
      number: sessions.number,
      start:
        sql<string>`TO_CHAR(${sessions.start} AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')`.as(
          "start",
        ),
      end: sql<string>`TO_CHAR(${sessions.end} AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')`.as(
        "end",
      ),
      allDay: sql<false>`FALSE`,
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

  if (!result) {
    // One empty rounds, the 'session' id does not give a session and it should find it in the rounds
    const [result] = await db
      .select({
        id: concat(rounds.id, "-R-r0"),
        type: sql<SessionType | null>`'R'`,
        number: sql<number>`0`,
        start: sql<string>`TO_CHAR(${rounds.start}, 'YYYY-MM-DD')`.as("start"),
        end: sql<string>`TO_CHAR(${rounds.end}, 'YYYY-MM-DD')`.as("end"),
        allDay: sql<true>`TRUE`,
        year: sql<number>`DATE_PART('year', ${rounds.start})`,
        weekNumber: sql<number>`DATE_PART('week', ${rounds.start})`,
        weekendOffset: sql<number>`DATE_PART('week', ${rounds.start}) - DATE_PART('week', NOW())`,
        series: rounds.series,
        roundTitle: sql<string | null>`${rounds.title}`,
        link: rounds.link,
        country: circuits.country,
        locality: circuits.locality,
        circuitTitle: circuits.title,
        lat: circuits.lat,
        lon: circuits.lon,
      })
      .from(rounds)
      .leftJoin(circuits, eq(rounds.circuitId, circuits.id))
      .where(eq(rounds.id, id.slice(0, -5)))
      .limit(1);
    return result;
  }

  return result;
};

export const getWeekend = async (weekendOffset = 0) => {
  const [start, end] = getWeekendDatesFromOffset(weekendOffset);

  const allEmptyRounds = db
    .select({
      id: concat(rounds.id, "-R-r0"),
      type: sql<SessionType | null>`'R'`,
      number: sql<number>`0`,
      start: sql<string>`TO_CHAR(${rounds.start}, 'YYYY-MM-DD')`.as("start"),
      end: sql<string>`TO_CHAR(${rounds.end}, 'YYYY-MM-DD')`.as("end"),
      allDay: sql<true>`TRUE`,
      year: sql<number>`DATE_PART('year', ${rounds.start})`,
      weekNumber: sql<number>`DATE_PART('week', ${rounds.start})`,
      weekendOffset: sql<number>`DATE_PART('week', ${rounds.start}) - DATE_PART('week', NOW())`,
      series: rounds.series,
      roundTitle: sql<string | null>`${rounds.title}`,
      link: rounds.link,
      country: circuits.country,
      locality: circuits.locality,
      circuitTitle: circuits.title,
      lat: circuits.lat,
      lon: circuits.lon,
    })
    .from(rounds)
    .leftJoin(circuits, eq(rounds.circuitId, circuits.id))
    .where(
      and(
        notInArray(
          rounds.id,
          db.selectDistinct({ roundId: sessions.roundId }).from(sessions),
        ),
        gte(rounds.start, start.toString()),
        lte(rounds.end, end.toString()),
      ),
    );

  const allSessions = db
    .select({
      id: sessions.id,
      type: sessions.type,
      number: sessions.number,
      start:
        sql<string>`TO_CHAR(${sessions.start} AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')`.as(
          "start",
        ),
      end: sql<string>`TO_CHAR(${sessions.end} AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')`.as(
        "end",
      ),
      allDay: sql<false>`FALSE`,
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
    .leftJoin(circuits, eq(rounds.circuitId, circuits.id))
    .where(
      and(gte(rounds.start, start.toString()), lte(rounds.end, end.toString())),
    );
  // @ts-ignore FIXME:
  return allEmptyRounds.union(allSessions);
};
