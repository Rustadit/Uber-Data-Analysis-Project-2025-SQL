--Q.7 Identify the top 5 Pickup Localities in each city with the highest cancellation rates to pinpoint areas where drivers are most reluctant to go.

    --Ranks the localities based on the cancellation rate
    WITH locality_wise_cancellation_rate AS
			  (SELECT c1_id,
    		   c1_name,
    		   pickup_location,
    		   cancellation_rate,
    		   RANK() OVER (PARTITION BY c1_name ORDER BY cancellation_rate DESC) ranking
    		   FROM (WITH city_wise_driver_cancellation_count AS
    				 								--this table calculates city-wise rides cancelled by drivers
    				 								(SELECT c.city_id c1_id,
    					   		 				 			c.city_name c1_name,
    					   		 	 			 			COUNT(status) city_cancellation_count
    												 FROM cities c
    												 JOIN drivers d
    												 ON c.city_id=d.city_id
    												 JOIN rides r
    												 ON r.driver_id=d.driver_id
    												 WHERE r.status='Cancelled by Driver'
    												 GROUP BY 1,2),

    					  locality_wise_driver_cancellation_count AS
													--this table calculates locality-wise rides cancelled by drivers
    											    (SELECT c.city_id c2_id,
    								   	 	   				c.city_name c2_name,
    								   		   				r.pickup_location,
    								   		   				COUNT(r.status) locality_cancellation_count
    											     FROM cities c
    											     JOIN drivers d
    											     ON c.city_id=d.city_id
    											     JOIN rides r
    											     ON r.driver_id=d.driver_id
    											     WHERE r.status='Cancelled by Driver'
    											     GROUP BY 1,2,3)

    				  --this table gives the locality-wise cancellation rate by driver for each city
    				  SELECT *,
							 (locality_cancellation_count/(city_cancellation_count::float))*100 cancellation_rate
    				  FROM city_wise_driver_cancellation_count
    				  JOIN locality_wise_driver_cancellation_count
    				  ON city_wise_driver_cancellation_count.c1_id=locality_wise_driver_cancellation_count.c2_id))

    SELECT c1_id city_id,
    	   c1_name city_name,
    	   pickup_location,
    	   cancellation_rate,
    	   ranking
    FROM locality_wise_cancellation_rate
    WHERE ranking<=5;
