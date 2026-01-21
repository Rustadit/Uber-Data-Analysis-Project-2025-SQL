--Q.11 Compare the Completion-to-Cancellation Ratio for rides booked via different modes of payment to identify if specific payment methods lead to higher rider flake rates.

    --Computes the number of rides completed and canclled across each payment method
    WITH payment_mode_status_count AS
		(SELECT payment_mode,
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
