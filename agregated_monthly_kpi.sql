-- Monthly KPI Dashboard Query
WITH monthly_kpis AS (
    SELECT 
        DATE_TRUNC('month', interaction_date) as report_month,
        region,
        
        -- Call Acceptance Rate (within 2 minutes)
        ROUND(
            AVG(CASE WHEN touchpoint_type = 'call' THEN accepted_within_sla END) * 100, 2
        ) as call_acceptance_rate,
        
        -- Chat Acceptance Rate (within 30 seconds)
        ROUND(
            AVG(CASE WHEN touchpoint_type = 'chat' THEN accepted_within_sla END) * 100, 2
        ) as chat_acceptance_rate,
        
        -- Email Acceptance Rate (within 24 hours)
        ROUND(
            AVG(CASE WHEN touchpoint_type = 'email' THEN accepted_within_sla END) * 100, 2
        ) as email_acceptance_rate,
        
        -- Issue Resolution Rate (within 24 hours)
        ROUND(AVG(resolved_within_24h) * 100, 2) as issue_resolution_rate,
        
        -- Customer Satisfaction Score
        ROUND(AVG(csat_score), 2) as avg_csat_score,
        
        -- Volume metrics
        COUNT(*) as total_interactions,
        COUNT(DISTINCT customer_id) as unique_customers
        
    FROM unified_touchpoints
    WHERE interaction_date >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY DATE_TRUNC('month', interaction_date), region
)

SELECT 
    report_month,
    region,
    call_acceptance_rate,
    chat_acceptance_rate,
    email_acceptance_rate,
    issue_resolution_rate,
    avg_csat_score,
    total_interactions,
    unique_customers
FROM monthly_kpis
ORDER BY report_month DESC, region;