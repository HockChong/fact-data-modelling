INSERT INTO chong.host_activity_reduced
-- incremental load for Aug-2023 dataset
-- increase the today date by 1 for the incremental load, other dates value remain unchanged
WITH yesterday AS (
  -- pull yesterday’s reduced metrics for comparison (already aggregated state as of 2023-08-01)
  SELECT * 
  FROM chong.host_activity_reduced
  WHERE month_start = '2023-08-01'
),
today AS (
  -- get today’s fresh metrics (incremental data slice for 2023-08-03)
  SELECT * 
  FROM chong.daily_web_metrics
  WHERE date = DATE('2023-08-03')
)

SELECT 
    -- combine user_id from both yesterday and today
    COALESCE(t.user_id, y.user_id) AS user_id,
    -- combine metric_name from both yesterday and today
    COALESCE(t.metric_name, y.metric_name) AS metric_name,
    -- extend yesterday’s metric_array by appending today’s value
    -- fill earlier days with NULL if user/metric appears for the first time
    COALESCE(
        y.metric_array, 
        REPEAT(null, CAST(DATE_DIFF('day', DATE('2023-08-01'), t.DATE) AS INTEGER))
    ) || ARRAY[t.metric_value] AS metric_array,
    -- keep the month_start fixed for partition alignment
    '2023-08-01' AS month_start
FROM today t
FULL OUTER JOIN yesterday y 
    ON t.user_id = y.user_id
   AND t.metric_name = y.metric_name;
