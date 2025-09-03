-- Create a new table to store reduced host activity metrics
CREATE TABLE chong.host_activity_reduced (
  user_id BIGINT,                          -- Unique identifier for each user
  metric_name VARCHAR,                     -- Name of the metric being tracked (e.g., login_count, sessions)
  metric_array ARRAY(INTEGER),             -- Array storing metric values (e.g., daily activity as integers)
  month_start VARCHAR                      -- The month (e.g., '2023-01-01') that this record corresponds to
)
WITH (
  format = 'PARQUET',                      -- Store data in Parquet format for efficient storage & querying
  partitioning = ARRAY['metric_name', 'month_start']  -- Partition by metric_name & month_start for faster queries
);


