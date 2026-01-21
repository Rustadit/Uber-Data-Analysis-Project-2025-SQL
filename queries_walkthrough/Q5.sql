--Q.5 Compute the vehicle fleet coverage in terms of Total bookings, Success rate, Average distance and Total distance.

    SELECT v.vehicle_type,
    	   COUNT(*) total_bookings,
    	   ((COUNT(CASE WHEN r.status='Completed' THEN 1 END)/COUNT(r.*)::float)*100) AS success_rate,
    	   AVG(distance_km) avg_distance,
    	   SUM(distance_km) total_distance
    FROM vehicles v
    JOIN drivers d
    ON v.vehicle_id=d.vehicle_id
    JOIN rides r
    ON r.driver_id=d.driver_id
    GROUP BY 1
    ORDER BY 2 DESC;
