-- Create a new table to store host activity in cumulative format
CREATE TABLE chong.hosts_cumulated (
  host VARCHAR,                      -- The host identifier
  host_activity_datelist ARRAY(date),-- Array of dates when the host was active
  date DATE                          -- Snapshot date (used as partition key)
)
WITH (
  format = 'PARQUET',                -- Store data in efficient Parquet format
  partitioning = ARRAY['date']       -- Partition the table by snapshot date for faster queries
);
