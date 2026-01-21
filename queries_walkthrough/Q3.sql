--Q.3 Identify the Top 5% of Power Riders in each city who contribute to the highest cumulative revenue, and determine if their preferred payment mode differs from the bottom 95%.

    -- Step 1: Calculate cumulative revenue per user per city
    WITH user_revenue AS
        (SELECT
         u.User_ID,
         c.City_Name,
         SUM(r.fare_inr) AS total_revenue,
         COUNT(r.ride_id) AS total_rides
         FROM rides r
         JOIN app_sessions apps ON r.session_id = apps.session_id
         JOIN users u ON apps.user_id = u.user_id
         JOIN cities c ON u.city_id = c.city_id
         WHERE r.status = 'Completed'
         GROUP BY u.user_id, c.city_name),

    -- Step 2: Identify the Top 5% in each city using PERCENT_RANK
         user_segmentation AS
        (SELECT
         user_id,
         city_name,
         CASE WHEN PERCENT_RANK() OVER (PARTITION BY city_Name ORDER BY total_revenue DESC) <= 0.05
              THEN 'Top 5% (Power Riders)'
              ELSE 'Bottom 95% (Regular Riders)'
              END AS rider_cohort
        FROM user_revenue),

    -- Step 3: Count payment modes per cohort
        cohort_payment_stats AS
        (SELECT
         us.rider_cohort,
         r.payment_Mode,
         COUNT(r.ride_id) AS ride_count
         FROM rides r
         JOIN app_sessions apps ON r.session_id = apps.session_id
         JOIN user_segmentation us ON apps.user_id = us.user_id
         WHERE r.status = 'Completed'
         GROUP BY us.rider_cohort, r.payment_Mode)

    -- Step 4: Final Comparison (Percentage Distribution)
    SELECT
    rider_cohort,
    Payment_Mode,
    ride_count,
    ROUND(ride_count * 100.0 / SUM(ride_count) OVER (PARTITION BY rider_cohort), 2) AS percent_share
    FROM cohort_payment_stats
    ORDER BY rider_cohort, percent_share DESC;
