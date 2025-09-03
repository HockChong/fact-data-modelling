WITH daily_active AS (
    SELECT
        da.user_id,
        da.browser_type,
        t.valid_date,
        -- Mark as true if valid_date is inside the array column da.date_active
        CONTAINS(da.date_active, t.valid_date) AS is_active,
        -- Calculate offset in days from snapshot_date (2023-01-07) to valid_date
        DATE_DIFF('day', DATE '2023-01-07', t.valid_date) AS day_offset
    FROM chong.device_activity_datelist da
    -- Generate all dates from 2023-01-01 to 2023-01-07 (7-day window)
    CROSS JOIN UNNEST(
        SEQUENCE(DATE '2023-01-01', DATE '2023-01-07', INTERVAL '1' DAY)
    ) AS t(valid_date)
    -- Filter only rows with snapshot_date = 2023-01-07
    WHERE da.date = DATE '2023-01-07'
),
bits AS (
    SELECT
        user_id,
        browser_type,
        -- Build array of '1'/'0' bits ordered by valid_date
        ARRAY_AGG(
            CASE WHEN is_active THEN '1' ELSE '0' END
            ORDER BY valid_date
        ) AS bit_array
    FROM daily_active
    GROUP BY user_id, browser_type
)
SELECT
    user_id,
    browser_type,
    -- Convert bit_array into a single string like '1000110'
    ARRAY_JOIN(bit_array, '') AS datelist_bits,
    -- Keep snapshot date for reference
    DATE '2023-01-07' AS snapshot_date
FROM bits;

