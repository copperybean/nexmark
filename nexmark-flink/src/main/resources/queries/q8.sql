-- -------------------------------------------------------------------------------------------------
-- Query 8: Monitor New Users
-- -------------------------------------------------------------------------------------------------
-- Select people who have entered the system and created auctions in the last period.
-- Illustrates a simple join.
--
-- The original Nexmark Query8 monitors the new users the last 12 hours, updated every 12 hours.
-- To make things a bit more dynamic and easier to test we use much shorter windows (10 seconds).
-- -------------------------------------------------------------------------------------------------

CREATE TABLE nexmark_q8 (
  id  BIGINT,
  name  VARCHAR,
  stime  TIMESTAMP(3)
) WITH (
  'connector' = 'blackhole'
);

INSERT INTO nexmark_q8
SELECT P.id, P.name, P.starttime
FROM (
  SELECT id, name,
        window_start AS starttime,
        window_end AS endtime
  FROM TABLE(
            TUMBLE(TABLE person, DESCRIPTOR(`dateTime`), INTERVAL '10' SECOND))
  GROUP BY id, name, window_start, window_end
) P
JOIN (
  SELECT seller,
        window_start AS starttime,
        window_end AS endtime
  FROM TABLE(
        TUMBLE(TABLE auction, DESCRIPTOR(`dateTime`), INTERVAL '10' SECOND))
  GROUP BY seller, window_start, window_end
) A
ON P.id = A.seller AND P.starttime = A.starttime AND P.endtime = A.endtime;