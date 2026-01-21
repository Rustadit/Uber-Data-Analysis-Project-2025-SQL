--Q.13 Evaluate device-driven differences in conversion, value generation, and engagement

    SELECT apps.device,
           COUNT(*) total_sessions,
           COUNT(CASE WHEN r.status='Completed' THEN 1 END) total_rides,
           ((COUNT(CASE WHEN r.status='Completed' THEN 1 END)/(COUNT(*)::FLOAT))*100) conversion_rate,
           AVG(r.fare_inr) revenue_per_session
    FROM app_sessions apps
    JOIN rides r
    ON apps.session_id=r.session_id
    GROUP BY 1;
