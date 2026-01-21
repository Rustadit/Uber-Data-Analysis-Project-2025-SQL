--Q.9 Identify the specific Hour of the Day with the highest frequency of 'No Driver Found' statuses to assist in optimizing surge pricing windows

    SELECT DATE_PART('HOUR',request_ts) hour_of_the_day,
    	   COUNT(status) no_driver_found_count
    FROM rides
    WHERE status='No Driver found'
    GROUP BY 1
    ORDER BY 1 DESC
    LIMIT 1;
