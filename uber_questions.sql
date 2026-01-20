--Financial & Marketplace Performance

--Q.1 Measure the Gross Platform Revenue for each region and rank them from highest to lowest to identify which market is currently the primary revenue driver.

    SELECT c.region,
           (SUM(r.fare_inr)/4) gross_platform_revenue,
           RANK() OVER (ORDER BY (SUM(r.fare_inr)/4) DESC) ranking
    FROM cities c
    JOIN drivers d
    ON c.city_id=d.city_id
    JOIN rides r
    ON r.driver_id=d.driver_id
    GROUP BY 1


--Q.2 Measure city-level performance by calculating Gross Platform Revenue, Platform Revenue Loss (Potential revenue lost to "No Driver Found" and "Cancelled by Driver" statuses) to evaluate marketplace health across cities) and Total Loss.

    --plarform revenue loss has been calculated by counting the rides cancelled by driver or the rides for which status was "No driver found" and multiplying it by average ride fare in that corresponding city
    SELECT c1_name city_name, (total_platform_revenue/4) AS gross_platform_revenue, ((no_driver_found_count+driver_cancelled_count)*completed_rides_avg_fare)/4 AS platform_revenue_loss, ((no_driver_found_count+driver_cancelled_count)*completed_rides_avg_fare) AS total_loss
    FROM (WITH completed_rides_revenue as
                 --this table calculates city-wise revenue for completed rides
                (SELECT c.city_id, c.city_name c1_name , AVG(r.fare_inr) completed_rides_avg_fare, SUM(r.fare_inr) total_platform_revenue
            	   FROM cities c
            	   JOIN drivers d
            	   ON c.city_id=d.city_id
            	   JOIN rides r
                 ON r.driver_id=d.driver_id
            	   GROUP BY 1),

                  --this table calculates city-wise count of bookings with no drivers found
    	         no_driver_found_table as
                (SELECT c.city_id, c.city_name c2_name, count(r.status) no_driver_found_count
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
    	        driver_cancelled_table as
               (SELECT c.city_id, c.city_name c3_name, count(r.status) driver_cancelled_count
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
	  ON no_driver_found_table.city_id=driver_cancelled_table.city_id)


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


--Q.4 Calculate the Month-over-Month (MoM) Growth Percentage in total completed ride volume to identify months with significant demand spikes or dips.

    --table of current month and previous month completed rides
    WITH month_wise_rides AS (SELECT date_trunc('month',request_ts) month_trunc,
    	  					  COUNT(*) no_of_completed_rides,
    	  					  LAG(COUNT(*)) OVER (ORDER BY date_trunc('month',request_ts)) previous_month_completed_rides
    	  					  FROM rides
    	  				      WHERE status='Completed'
    	  					  GROUP BY 1)

    SELECT TO_CHAR(month_trunc, 'Month') AS month_name,
    	   no_of_completed_rides,
    	   (((no_of_completed_rides-previous_month_completed_rides)::float)/previous_month_completed_rides) * 100 MoM_growth_percentage
    FROM month_wise_rides


--Operational & Logistics Efficiency

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


--Q.7 Identify the top 5 Pickup Localities in each city with the highest cancellation rates to pinpoint areas where drivers are most reluctant to go.

    --Ranks the localities based on the cancellation rate
    WITH locality_wise_cancellation_rate AS (SELECT c1_id,
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

    												--this table calculates locality-wise rides cancelled by drivers
    					  		  locality_wise_driver_cancellation_count AS
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
    					  SELECT *, (locality_cancellation_count/(city_cancellation_count::float))*100 cancellation_rate
    					  FROM city_wise_driver_cancellation_count
    					  JOIN locality_wise_driver_cancellation_count
    					  ON city_wise_driver_cancellation_count.c1_id=locality_wise_driver_cancellation_count.c2_id))

    SELECT c1_id city_id,
    	   c1_name city_name,
    	   pickup_location,
    	   cancellation_rate,
    	   ranking
    FROM locality_wise_cancellation_rate
    WHERE ranking<=5


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
    SELECT city_name,
           AVG(total_active_drivers) avg_total_active_drivers,
           AVG(under_utilized_count) avg_under_utilized_count,
           AVG(percent_under_utilized) avg_percent_under_utilized
    FROM under_utilized_drivers_ranking
    GROUP BY 1


--Q.9 Identify the specific Hour of the Day with the highest frequency of 'No Driver Found' statuses to assist in optimizing surge pricing windows

    SELECT DATE_PART('HOUR',request_ts) hour_of_the_day,
    	   COUNT(status) no_driver_found_count
    FROM rides
    WHERE status='No Driver found'
    GROUP BY 1
    ORDER BY 1 DESC
    LIMIT 1;


--User Behavior & Product Insights

--Q.10 Calculate the Session-to-Booked-Ride Conversion Rate to measure how effectively the app turns "browsing" users into "paying" riders.

    --Count of successful booked rides by user
    WITH booked_ride_count AS (SELECT COUNT(*) booked_ride_counts
    							             FROM (SELECT event_type,
    							                   LEAD(event_type) OVER (ORDER BY event_id) next_event
    							                   FROM app_events)
    							             WHERE event_type='your ride has been confirmed' AND next_event!='cancel the ride'),

    --Count of distinct sessions
         session_count AS (SELECT COUNT(DISTINCT session_id) session_counts
    					             FROM app_events)

    --Calculate the Conversion Percentage
    SELECT b.booked_ride_counts,
    	     s.session_counts,
    	     (b.booked_ride_counts/(s.session_counts::float))*100 session_to_booked_conversion_rate
    FROM booked_ride_count b, session_count s


--Q.11 Compare the Completion-to-Cancellation Ratio for rides booked via different modes of payment to identify if specific payment methods lead to higher rider flake rates.

    --Computes the number of rides completed and canclled across each payment method
    WITH payment_mode_status_count AS (SELECT payment_mode,
    	   															 COUNT(CASE WHEN status='Completed' THEN 1 END) completion_count,
    												   				 COUNT(CASE WHEN status='Cancelled by User' THEN 1 END) cancellation_count
    																	 FROM rides
    																	 GROUP BY 1)

    SELECT payment_mode,
    	   	 completion_count,
    	     cancellation_count,
    	     completion_count/(cancellation_count::float) completion_to_cancellation_ratio
    FROM payment_mode_status_count
    ORDER BY 4;


--Q.12 Perform an RFM Analysis to identify the total count of "At-Risk" users

    -- Step 1: Calculate raw R, F, and M
    WITH user_base_metrics AS
                      (SELECT u.user_id,
    				          ('2026-01-01'-MAX(r.request_ts::DATE)) AS recency,
    				           COUNT(r.ride_id) AS frequency,
    				           SUM(r.fare_inr) AS monetary
        						   FROM rides r
        						   JOIN app_sessions apps ON r.Session_ID = apps.Session_ID
        						   JOIN users u ON apps.user_id = u.user_id
        						   WHERE r.status = 'Completed'
        						   GROUP BY 1),

    -- Step 2: Assign scores from 1 to 5 using NTILE
    	   rfm_scores AS
                      (SELECT User_id,
    				           recency,
    				           frequency,
    				           monetary,
    				           NTILE(5) OVER (ORDER BY recency DESC) AS r_score, -- Note: High recency days = low score
    				           NTILE(5) OVER (ORDER BY frequency) AS f_score,
    				           NTILE(5) OVER (ORDER BY monetary) AS m_score
    				           FROM user_base_metrics)

    -- Step 3: Filter for the "At-Risk" segment
    SELECT COUNT(User_ID) AS at_risk_user_count,
           ROUND(AVG(monetary), 0) AS avg_historical_spend,
           ROUND(AVG(recency), 0) AS avg_days_since_last_ride
      	   FROM rfm_scores
      	   WHERE r_score <= 2       -- Haven't seen them in a long time
       	   AND (f_score >= 4 OR m_score >= 4); -- They were high-value/frequent in the past


--Q.13 Evaluate device-driven differences in conversion, value generation, and engagement

           SELECT apps.device,
           	     COUNT(*) total_sessions,
           	     COUNT(CASE WHEN r.status='Completed' THEN 1 END) total_rides,
           	     ((COUNT(CASE WHEN r.status='Completed' THEN 1 END)/(COUNT(*)::FLOAT))*100) conversion_rate,
           	     AVG(r.fare_inr) revenue_per_session
           FROM app_sessions apps
           JOIN rides r
           ON apps.session_id=r.session_id
           GROUP BY 1

