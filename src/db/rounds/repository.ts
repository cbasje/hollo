import { eq, sql } from "drizzle-orm";
import db from "..";
import {
  type SeriesId,
  type Session,
  type WeekendRound,
  circuits,
  rounds,
  sessions,
} from "../../hunter/schema";

const sessionSq = db.$with("children").as(
  db
    .select({
      roundId: sessions.roundId,
      sessions: sql<
        Session[]
      >`jsonb_agg(${sessions}.* ORDER BY ${sessions.start})`.as("sessions"),
    })
    .from(sessions)
    .groupBy(sessions.roundId),
);

const fields = {
  id: rounds.id,
  number: rounds.number,
  title: rounds.title,
  season: rounds.season,
  link: rounds.link,
  start: rounds.start,
  end: rounds.end,
  year: sql<number>`DATE_PART('year', ${rounds.start})`,
  weekNumber: sql<number>`DATE_PART('week', ${rounds.start})`,
  weekendOffset: sql<number>`DATE_PART('week', ${rounds.start}) - DATE_PART('week', NOW())`,
  circuitId: rounds.circuitId,
  series: rounds.series,
  country: circuits.country,
  locality: circuits.locality,
  circuitTitle: circuits.title,
  timezone: circuits.timezone,
  sessions: sql<Session[]>`COALESCE(${sessionSq.sessions}, '[]'::jsonb)`,
  isTest: sql<boolean>`${rounds.id} IN ${db
    .selectDistinct({ roundId: sessions.roundId })
    .from(sessions)
    .where(eq(sessions.type, "T"))}`,
} satisfies Record<keyof WeekendRound, unknown>;

export const getOne = async (id: string): Promise<WeekendRound> => {
  const [first] = await db
    .with(sessionSq)
    .select(fields)
    .from(rounds)
    .leftJoin(sessionSq, eq(sessionSq.roundId, rounds.id))
    .leftJoin(circuits, eq(rounds.circuitId, circuits.id))
    .where(eq(rounds.id, id))
    .limit(1);
  return first;
};

export const getAllBySeries = async (id: SeriesId): Promise<WeekendRound[]> => {
  const result = await db
    .with(sessionSq)
    .select(fields)
    .from(rounds)
    .leftJoin(sessionSq, eq(sessionSq.roundId, rounds.id))
    .leftJoin(circuits, eq(rounds.circuitId, circuits.id))
    .where(eq(rounds.series, id))
    .orderBy(rounds.start);
  return result;
};
