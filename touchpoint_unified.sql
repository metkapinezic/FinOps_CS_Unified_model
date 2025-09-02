WITH touchpoint_metrics AS (
    -- Call metrics
    SELECT 
        'call' as touchpoint_channel,
        fc.customer_id,
        fc.region,
        fc.call_start_time as interaction_date,
        fc.case_id,
        CASE 
            WHEN fc.queue_time_seconds <= 120 THEN 1 
            ELSE 0 
        END as accepted_within_sla,
        fc.queue_time_seconds as response_time_seconds,
        CASE 
            WHEN fc.call_status = 'answered' THEN 1 
            ELSE 0 
        END as interaction_completed
    FROM five9_calls fc
    WHERE fc.call_start_time >= CURRENT_DATE - INTERVAL '30 days'
    
    UNION ALL
    
    -- Chat metrics
    SELECT 
        'chat' as touchpoint_channel,
        wc.customer_id,
        wc.region,
        wc.chat_start_time as interaction_date,
        wc.case_id,
        CASE 
            WHEN wc.response_time_seconds <= 30 THEN 1 
            ELSE 0 
        END as accepted_within_sla,
        wc.response_time_seconds,
        CASE 
            WHEN wc.chat_status IN ('resolved', 'transferred') THEN 1 
            ELSE 0 
        END as interaction_completed
    FROM whatsapp_chats wc
    WHERE wc.chat_start_time >= CURRENT_DATE - INTERVAL '30 days'
    
    UNION ALL
    
    -- Email metrics
    SELECT 
        'email' as touchpoint_channel,
        sc.customer_id,
        sc.region,
        sc.created_date as interaction_date,
        sc.case_id,
        CASE 
            WHEN sc.response_time_hours <= 24 THEN 1 
            ELSE 0 
        END as accepted_within_sla,
        sc.response_time_hours * 3600 as response_time_seconds,
        CASE 
            WHEN sc.case_status IN ('resolved', 'closed') THEN 1 
            ELSE 0 
        END as interaction_completed
    FROM salesforce_cases sc
    WHERE sc.case_type = 'email'
      AND sc.created_date >= CURRENT_DATE - INTERVAL '30 days'
),

resolution_metrics AS (
    SELECT 
        sc.case_id,
        sc.customer_id,
        sc.region,
        sc.created_date,
        sc.case_category  as touchpoint_category,
        sc.case_sub_category as touchpoint_sub_category,
        sc.product_area,
        sc.first_contact_resolution BOOLEAN DEFAULT FALSE
        CASE 
            WHEN sc.resolution_time_hours <= 24 AND sc.case_status IN ('resolved', 'closed') THEN 1 
            ELSE 0 
        END as resolved_within_24h
    FROM salesforce_cases sc
    WHERE sc.created_date >= CURRENT_DATE - INTERVAL '30 days'
),

unified_touchpoints AS (
    SELECT 
        tm.touchpoint_channel,
        tm.customer_id,
        tm.region,
        DATE(tm.interaction_date) as interaction_date,
        tm.case_id,
        rm.touchpoint_category,
        rm.touchpoint_sub_category,
        rm.product_area,
        tm.accepted_within_sla,
        tm.response_time_seconds,
        tm.interaction_completed,
        rm.resolved_within_24h,
        mc.csat_score,
        mc.csat_date,
        ROW_NUMBER() OVER (
            PARTITION BY tm.customer_id, tm.touchpoint_channel, DATE(tm.interaction_date) 
            ORDER BY tm.interaction_date DESC
        ) as daily_interaction_rank
    FROM touchpoint_metrics tm
    LEFT JOIN merchant_customers mc ON tm.customer_id = mc.customer_id
    LEFT JOIN resolution_metrics rm ON tm.case_id = rm.case_id
)

-- Final unified model with KPIs
SELECT 
    touchpoint_channel,
    region,
    interaction_date,
    customer_segment,
    
    -- Volume Metrics
    COUNT(*) as total_interactions,
    COUNT(DISTINCT customer_id) as unique_customers,
    COUNT(DISTINCT case_id) as total_cases,
    COUNT(DISTINCT touchpoint_category) as distinct_touchpoint_categories,
    COUNT(DISTINCT product_area) as distinct_product_areas,
    
    -- Acceptance Rate KPIs
    ROUND(
        AVG(CASE WHEN touchpoint_channel = 'call' THEN accepted_within_sla END) * 100, 2
    ) as call_acceptance_rate_pct,
    
    ROUND(
        AVG(CASE WHEN touchpoint_channel = 'chat' THEN accepted_within_sla END) * 100, 2
    ) as chat_acceptance_rate_pct,
    
    ROUND(
        AVG(CASE WHEN touchpoint_channel = 'email' THEN accepted_within_sla END) * 100, 2
    ) as email_acceptance_rate_pct,
    
    -- Resolution Rate KPI
    ROUND(AVG(resolved_within_24h) * 100, 2) as issue_resolution_rate_pct,
    
    -- Customer Satisfaction KPI
    ROUND(AVG(csat_score), 2) as avg_csat_score,
    COUNT(CASE WHEN csat_score IS NOT NULL THEN 1 END) as csat_responses,
    
    -- Response Time Metrics
    ROUND(AVG(response_time_seconds), 0) as avg_response_time_seconds,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY response_time_seconds), 0) as median_response_time_seconds,
    
    -- Completion Rate
    ROUND(AVG(interaction_completed) * 100, 2) as completion_rate_pct

FROM unified_touchpoints
WHERE daily_interaction_rank = 1  -- Deduplicate multiple daily interactions, uses most recent one
GROUP BY 
    touchpoint_channel,
    region,
    interaction_date,
    customer_segment
ORDER BY 
    interaction_date DESC,
    region,
    touchpoint_channel;
