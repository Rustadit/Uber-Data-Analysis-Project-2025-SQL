--Q.8 Identify the percentage of Under-Utilized Drivers by calculating the count of those whose monthly trip volume falls in the bottom 25% of all active drivers in their city.

    WITH under_utilized_drivers_ranking AS
        -- Step 1: Calculate total completed trips per driver per month
        (WITH driver_monthly_trips AS
            (SELECT
             d.driver_id,
             c.city_name,
             DATE_PART('MONTH',r.request_ts) AS trip_month,
             COUNT(r.ride_id) AS monthly_trips
             FROM rides r
             JOIN drivers d ON r.driver_id = d.driver_id
             JOIN cities c ON d.city_id = c.city_id
             WHERE r.status = 'Completed'
             GROUP BY 1, 2, 3),

        -- Step 2: Rank drivers within their city and month
              driver_rankings AS
             (SELECT
                 *,
                 PERCENT_RANK() OVER (PARTITION BY city_name, trip_month ORDER BY monthly_trips) AS utilization_rank
              FROM driver_monthly_trips)

        -- Step 3: Identify the percentage of Under-Utilized Drivers
        SELECT
            city_name,
            trip_month,
            COUNT(driver_id) AS total_active_drivers,
            SUM(CASE WHEN utilization_rank <= 0.25 THEN 1 ELSE 0 END) AS under_utilized_count,
            ROUND((SUM(CASE WHEN utilization_rank <= 0.25 THEN 1 ELSE 0 END) * 100.0) / COUNT(driver_id),2) AS percent_under_utilized
        FROM driver_rankings
        GROUP BY 1, 2)

    --Step 4: Averaging the results across all months for each city
    SELECT
		   city_name,
           AVG(total_active_drivers) avg_total_active_drivers,
           AVG(under_utilized_count) avg_under_utilized_count,
           AVG(percent_under_utilized) avg_percent_under_utilized
    FROM under_utilized_drivers_ranking
    GROUP BY 1;
