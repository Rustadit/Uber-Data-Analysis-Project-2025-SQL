--Q.2 Measure city-level performance by calculating Gross Platform Revenue, Platform Revenue Loss (Potential revenue lost to "No Driver Found" and "Cancelled by Driver" statuses) to evaluate marketplace health across cities) and Total Loss.

    --Platform revenue loss has been calculated by counting the rides cancelled by driver or the rides for which status was "No driver found" and multiplying it by average ride fare in that corresponding city
    SELECT c1_name city_name, (total_platform_revenue/4) AS gross_platform_revenue,
		   ((no_driver_found_count+driver_cancelled_count)*completed_rides_avg_fare)/4 AS platform_revenue_loss,
		   ((no_driver_found_count+driver_cancelled_count)*completed_rides_avg_fare) AS total_loss
    FROM (WITH completed_rides_revenue AS
                --this table calculates city-wise revenue for completed rides
                (SELECT c.city_id,
						c.city_name c1_name,
						AVG(r.fare_inr) completed_rides_avg_fare,
						SUM(r.fare_inr) total_platform_revenue
            	 FROM cities c
                 JOIN drivers d
            	 ON c.city_id=d.city_id
            	 JOIN rides r
                 ON r.driver_id=d.driver_id
            	 GROUP BY 1),

                --this table calculates city-wise count of bookings with no drivers found
    	         no_driver_found_table AS
                (SELECT c.city_id,
						c.city_name c2_name,
						count(r.status) no_driver_found_count
        	     FROM cities c
        	     JOIN users u
        	     ON c.city_id=u.city_id
        	     JOIN app_sessions apps
        	     ON apps.user_id=u.user_id
        	     JOIN rides r
        	     ON r.session_id=apps.session_id
        	     WHERE status='No Driver found'
        	     GROUP BY 1),

                --this table calculates city-wise count of bookings cancelled by driver
    	        driver_cancelled_table AS
               (SELECT c.city_id,
					   c.city_name c3_name,
					   count(r.status) driver_cancelled_count
      	        FROM cities c
      	        JOIN users u
      	        ON c.city_id=u.city_id
      	        JOIN app_sessions apps
      	        ON apps.user_id=u.user_id
      	        JOIN rides r
      	        ON r.session_id=apps.session_id
      	        WHERE status='Cancelled by Driver'
      	        GROUP BY 1)

      --the table merges the three tables to give combined results across cities
	  SELECT *
	  FROM completed_rides_revenue
	  JOIN no_driver_found_table
	  ON completed_rides_revenue.city_id=no_driver_found_table.city_id
	  JOIN driver_cancelled_table
	  ON no_driver_found_table.city_id=driver_cancelled_table.city_id);
