CREATE TABLE salesforce_cases (
    case_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    agent_id VARCHAR(50),
    case_type VARCHAR(20) CHECK (case_type IN ('email', 'phone', 'chat', 'web')),
    case_reason VARCHAR(100),
    case_priority VARCHAR(10) CHECK (case_priority IN ('low', 'medium', 'high', 'urgent')),
    created_date TIMESTAMP NOT NULL,
    first_response_date TIMESTAMP,
    resolved_date TIMESTAMP,
    case_status VARCHAR(20) CHECK (case_status IN ('open', 'pending', 'resolved', 'closed')),
    region VARCHAR(10) NOT NULL,
    response_time_hours DECIMAL(10,2),
    resolution_time_hours DECIMAL(10,2),
    case_sub_reason VARCHAR(100),
    case_reason_category VARCHAR(50),
    issue_severity VARCHAR(20) CHECK (issue_severity IN ('critical', 'high', 'medium', 'low')),
    product_area VARCHAR(50),
    first_contact_resolution BOOLEAN DEFAULT FALSE
    

);