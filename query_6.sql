-- Insert new snapshot into chong.hosts_cumulated
INSERT INTO chong.hosts_cumulated
WITH yesterday AS (
  -- Get yesterday's snapshot (2022-12-31) from hosts_cumulated
  SELECT * 
  FROM chong.hosts_cumulated
  WHERE DATE = DATE('2022-12-31')
),

today AS (
  -- Aggregate today's activity (2023-01-01) from raw web events
  SELECT 
    host,                          -- host identifier
    count(*) AS activity,          -- number of events for the host today
    CAST(event_time AS DATE) date  -- today's date extracted from event_time
  FROM bootcamp.web_events
  WHERE CAST(event_time AS DATE) = DATE('2023-01-01')
  GROUP BY 1,3
)

-- Build today's snapshot by combining yesterday + today
SELECT
  COALESCE(t.host, y.host) AS host,   -- keep host even if missing from today/yesterday
  reverse(                            -- reverse array so most recent dates come first
    array_sort(                       -- sort activity dates in ascending order
      COALESCE(y.host_activity_datelist, CAST(ARRAY[] AS ARRAY<date>)) -- yesterday's history
      || ARRAY[t.date]                -- append today's date
    )
  ) AS host_activity_datelist,
  DATE('2023-01-01') AS date          -- snapshot date
FROM today t 
FULL OUTER JOIN yesterday y
ON t.host = y.host;                   -- join today with yesterday on host
