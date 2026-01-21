--Q.6 Measure the average Driver Arrival Lag (time between ride confirmation and arrival) for each city to identify where traffic or supply density is causing the most delay.

    SELECT c.city_name,
    	   AVG(r.arrival_ts-r.confirmation_ts) avg_driver_arrival_lag
    FROM cities c
    JOIN drivers d
    ON c.city_id=d.city_id
    JOIN rides r
    ON r.driver_id=d.driver_id
    WHERE status='Completed'
    GROUP BY 1
    ORDER BY 2 DESC;
