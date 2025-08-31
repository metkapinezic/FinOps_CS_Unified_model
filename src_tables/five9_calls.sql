CREATE TABLE five9_calls (
    call_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    agent_id VARCHAR(50),
    call_start_time TIMESTAMP NOT NULL,
    call_answer_time TIMESTAMP,
    call_end_time TIMESTAMP,
    queue_time_seconds INTEGER,
    call_duration_seconds INTEGER,
    call_status VARCHAR(20) CHECK (call_status IN ('answered', 'abandoned', 'transferred')),
    region VARCHAR(10) NOT NULL,
    case_id VARCHAR(50)
    
);