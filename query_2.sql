
-- Create a table in Trino to store cumulative user device activity
CREATE TABLE chong.device_activity_datelist
 (
    user_id BIGINT,              -- Unique identifier for the user
    browser_type VARCHAR,        -- Browser type used (e.g., Chrome, Safari)
    date_active ARRAY(DATE),     -- Array of active dates for this user
    date DATE                    -- Reference date for the cumulative snapshot
)
WITH (
    format = 'PARQUET',          -- Optional: store in columnar Parquet format for efficiency
    partitioning = ARRAY['date'] -- Partition table by the snapshot date
);