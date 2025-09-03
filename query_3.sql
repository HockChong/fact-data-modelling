-- Insert into the cumulated user-device activity datelist table
INSERT INTO chong.device_activity_datelist
WITH
  -- Yesterday's snapshot of user activity
  yesterday AS (
    SELECT
      user_id,
      browser_type,
      date_active
    FROM chong.device_activity_datelist
    WHERE DATE = DATE '2022-12-31' -- snapshot from previous day
  ),

  -- Today's activity: join web_events with devices to capture browser_type
  today AS (
    SELECT
      CAST(w.user_id AS BIGINT) AS user_id,  -- ensure type alignment
      d.browser_type,                        -- device/browser dimension
      DATE '2023-01-01' AS today_date        -- anchor date for today's run
    FROM bootcamp.web_events w
    JOIN bootcamp.devices d
      ON w.device_id = d.device_id
    WHERE CAST(w.event_time AS DATE) = DATE '2023-01-01'  -- filter today's events
      AND w.user_id IS NOT NULL                          -- ignore null users
    GROUP BY 1, 2, 3  -- ensure uniqueness at (user, browser_type, date) level
  )

-- Merge yesterday's and today's activity into a new snapshot
SELECT
  COALESCE(t.user_id, y.user_id) AS user_id,             -- prefer today's user_id if exists
  COALESCE(t.browser_type, y.browser_type) AS browser_type, -- prefer today's browser_type if exists

  -- Build the active date array (most recent first):
  --  - Add today's date if active
  --  - Preserve historical dates from yesterday
  TRANSFORM(
    REVERSE(SEQUENCE(DATE '2023-01-01', DATE '2023-01-01')), -- one-day sequence, reversed for recency
    d -> IF(
      (t.today_date IS NOT NULL AND d = t.today_date)        -- if user active today
      OR CONTAINS(COALESCE(y.date_active, CAST(ARRAY[] AS ARRAY(DATE))), d), -- or already active from history
      d,                                                     -- keep the date
      CAST(NULL AS DATE)                                     -- else store NULL (placeholder)
    )
  ) AS date_active,

  DATE '2023-01-01' AS DATE  -- snapshot date for this insert
FROM today t
FULL OUTER JOIN yesterday y
  ON t.user_id = y.user_id
 AND t.browser_type = y.browser_type;
