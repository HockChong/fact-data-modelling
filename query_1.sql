-- This query deduplicates game_details by keeping the first occurrence of each (game_id, team_id, player_id) combination
WITH deduped AS (
    SELECT
        -- Assign a row number within each (game_id, team_id, player_id) group
        ROW_NUMBER() OVER (
            PARTITION BY gd.game_id, gd.team_id, gd.player_id 
            ORDER BY g.game_date_est     -- Ensures deterministic ordering in Trino
        ) AS row_number,

        g.game_date_est,  -- Game date from the games table
        gd.*              -- All columns from game_details
    FROM game_details gd
    JOIN games g 
        ON gd.game_id = g.game_id   -- Join to get the game_date_est
)

-- Select only the first row for each (game_id, team_id, player_id)
SELECT *
FROM deduped
WHERE row_number = 1;
