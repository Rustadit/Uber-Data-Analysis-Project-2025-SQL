--Q.1 Measure the Gross Platform Revenue for each region and rank them from highest to lowest to identify which market is currently the primary revenue driver.

    SELECT c.region,
           (SUM(r.fare_inr)/4) gross_platform_revenue,
           RANK() OVER (ORDER BY (SUM(r.fare_inr)/4) DESC) ranking
    FROM cities c
    JOIN drivers d
    ON c.city_id=d.city_id
    JOIN rides r
    ON r.driver_id=d.driver_id
    GROUP BY 1;
