import { eq, inArray, sql } from "drizzle-orm";
import db from "..";
import {
  type SeriesId,
  type Session,
  circuits,
  rounds,
  sessions,
} from "../../hunter/schema";

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

export const getOne = async (id: string) => {
  const [first] = await db
    .with(sessionSq)
    .select({
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
      isTest: inArray(
        rounds.id,
        db
          .selectDistinct({ roundId: sessions.roundId })
          .from(sessions)
          .where(eq(sessions.type, "T")),
      ),
    })
    .from(rounds)
    .leftJoin(sessionSq, eq(sessionSq.roundId, rounds.id))
    .leftJoin(circuits, eq(rounds.circuitId, circuits.id))
    .where(eq(rounds.id, id))
    .limit(1);
  return first;
};
