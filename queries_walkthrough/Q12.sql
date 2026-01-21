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
