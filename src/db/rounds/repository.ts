import { eq, inArray, sql } from "drizzle-orm";
import db from "..";
import {
  type Circuit,
  type Round,
  type SeriesId,
  type Session,
  circuits,
  rounds,
  sessions,
} from "../../hunter/schema";

export type RoundExtended = {
  id: Round["id"];
  number: Round["number"];
  title: Round["title"];
  season: Round["season"];
  link: Round["link"];
  start: Round["start"];
  end: Round["end"];
  year: number;
  weekNumber: number;
  weekendOffset: number;
  circuitId: Round["circuitId"];
  series: Round["series"];
  country: Circuit["country"] | null;
  locality: Circuit["locality"] | null;
  circuitTitle: Circuit["title"] | null;
  timezone: Circuit["timezone"] | null;
  sessions: Session[];
  isTest: boolean;
};

const sessionSq = db.$with("children").as(
  db
    .select({
      roundId: sessions.roundId,
      sessions: sql<Session[]>`jsonb_agg(jsonb_build_object(
        'id', ${sessions.id},
        'number', ${sessions.number},
        'type', ${sessions.type}
      ))`.as("sessions"),
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
  sessions: sessionSq.sessions,
  isTest: sql<boolean>`${rounds.id} IN ${db
    .selectDistinct({ roundId: sessions.roundId })
    .from(sessions)
    .where(eq(sessions.type, "T"))}`,
} satisfies Record<keyof RoundExtended, unknown>;

export const getOne = async (id: string): Promise<RoundExtended> => {
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

export const getAllBySeries = async (
  id: SeriesId,
): Promise<RoundExtended[]> => {
  const result = await db
    .with(sessionSq)
    .select(fields)
    .from(rounds)
    .leftJoin(sessionSq, eq(sessionSq.roundId, rounds.id))
    .leftJoin(circuits, eq(rounds.circuitId, circuits.id))
    .where(eq(rounds.series, id));
  return result;
};
