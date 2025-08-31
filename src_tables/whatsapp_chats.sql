CREATE TABLE whatsapp_chats (
    chat_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    agent_id VARCHAR(50),
    chat_start_time TIMESTAMP NOT NULL,
    first_response_time TIMESTAMP,
    chat_end_time TIMESTAMP,
    response_time_seconds INTEGER,
    message_count INTEGER DEFAULT 0,
    chat_status VARCHAR(20) CHECK (chat_status IN ('resolved', 'transferred', 'abandoned')),
    region VARCHAR(10) NOT NULL,
    case_id VARCHAR(50)
);