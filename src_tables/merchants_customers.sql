CREATE TABLE merchant_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    region VARCHAR(10) NOT NULL,
    customer_segment VARCHAR(20) CHECK (customer_segment IN ('enterprise', 'mid-market', 'small-business')),
    registration_date DATE NOT NULL,
    account_status VARCHAR(20) CHECK (account_status IN ('active', 'inactive', 'suspended')),
    csat_score DECIMAL(3,2) CHECK (csat_score BETWEEN 1.00 AND 5.00),
    csat_date TIMESTAMP,
    total_cases INTEGER DEFAULT 0
    

);