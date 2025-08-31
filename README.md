# FinOps_CS_Unified_model
A unified customer touchpoint model is aimed at tracking operational KPIs in the customer support domain.

The objective of this model is to provide easy access for analysing the performance of the customer support department for the European markets.

List of KPIs that management was required to track and their calculations:
- Call Acceptance Rate: Percentage of calls answered within 2 minutes
- Chat Acceptance Rate: Percentage of chats responded to within 30 seconds
- Email Acceptance Rate: Percentage of emails responded to within 24 hours
- Issue Resolution Rate: Percentage of cases resolved within 24 hours
- CSAT Score: Average customer satisfaction rating (1-5 scale)

Raw data sources that were provided:
- Five9 (call data)
- WhatsApp (chat data)
- Salesforce (case data, email data)
- Merchants (customer data)

Key Model Features:

- Data Integration Points

Customer ID serves as the primary key linking all data sources
Case ID connects touchpoint interactions to resolution outcomes
Region field enables European market segmentation
Timestamp fields allow for SLA compliance calculations

- Model Benefits

Unified View: Single source of truth for all customer touchpoints
Performance Tracking: Real-time monitoring of acceptance and resolution rates
Regional Analysis: Market-specific performance insights
Trend Analysis: Historical performance tracking and forecasting
Customer Journey: Complete interaction history per customer
