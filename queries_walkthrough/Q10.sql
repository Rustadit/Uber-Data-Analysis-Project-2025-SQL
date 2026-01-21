--Q.10 Calculate the Session-to-Booked-Ride Conversion Rate to measure how effectively the app turns "browsing" users into "paying" riders.

    --Count of successful booked rides by user
    WITH booked_ride_count AS
		(SELECT COUNT(*) booked_ride_counts
    	 FROM (SELECT event_type,
    			      LEAD(event_type) OVER (ORDER BY event_id) next_event
    		   FROM app_events)
    	 WHERE event_type='your ride has been confirmed' AND next_event!='cancel the ride'),

    --Count of distinct sessions
         session_count AS
		(SELECT COUNT(DISTINCT session_id) session_counts
    	 FROM app_events)

    --Calculate the Conversion Percentage
    SELECT b.booked_ride_counts,
    	   s.session_counts,
    	   (b.booked_ride_counts/(s.session_counts::float))*100 session_to_booked_conversion_rate
    FROM booked_ride_count b, session_count s;
