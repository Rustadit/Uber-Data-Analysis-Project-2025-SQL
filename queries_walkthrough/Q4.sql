--Q.4 Calculate the Month-over-Month (MoM) Growth Percentage in total completed ride volume to identify months with significant demand spikes or dips.

    --table of current month and previous month completed rides
    WITH month_wise_rides AS
		(SELECT date_trunc('MONTH',request_ts) month_trunc,
    	        COUNT(*) no_of_completed_rides,
    			LAG(COUNT(*)) OVER (ORDER BY date_trunc('MONTH',request_ts)) previous_month_completed_rides
    	 FROM rides
    	 WHERE status='Completed'
    	 GROUP BY 1)

    SELECT TO_CHAR(month_trunc, 'MONTH') AS month_name,
    	   no_of_completed_rides,
    	   (((no_of_completed_rides-previous_month_completed_rides)::float)/previous_month_completed_rides) * 100 MoM_growth_percentage
    FROM month_wise_rides;
