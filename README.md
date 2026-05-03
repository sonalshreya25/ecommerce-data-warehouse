#  E-Commerce Analytics for Sales & Returns Optimization

##  Project Overview
This project focuses on designing and implementing a **data warehouse solution** for analyzing e-commerce sales and return data. The goal is to transform raw transactional data into a structured analytical model that enables efficient querying, insightful reporting, and data-driven decision-making.

The project demonstrates end-to-end data warehousing concepts including **data ingestion, transformation, dimensional modeling, analytical SQL, and visualization**.

---

##  Objectives
- Design a scalable **data warehouse (Snowflake)**
- Transform raw transactional data into a **dimensional model**
- Enable efficient analytical querying using SQL
- Analyze **sales performance and return behavior**
- Support decision-making for:
  - Revenue optimization  
  - Return reduction  
  - Operational efficiency  
  - Strategic planning  

---

##  Dataset
- Source: Kaggle E-commerce Sales Dataset  
- Content: Order-level transactional data  
- Includes:
  - Order details  
  - Product information  
  - Sales amount & quantity  
  - Shipping location  
  - Sales channel & fulfillment  
  - Order status (used for return analysis)  

---

##  Data Warehouse Architecture

###  Dimensional Model (Star Schema)
The warehouse follows a **star schema design** with:

### Fact Tables:
- `fact_sales` → Revenue-generating transactions  
- `fact_returns` → Return-related events  

### Dimension Tables:
- `dim_product` → Product attributes  
- `dim_time` → Time hierarchy (month, year, quarter)  
- `dim_geography` → Location (city, state, country)  
- `dim_sales_channel` → Channel & fulfillment details  
- `dim_promotion` → Promotion metadata  
- `dim_b2b_status` → Customer segment  

---

## Key Analysis & Insights

###  Sales Trends
- Sales show **irregular spikes**, indicating event-driven growth  
- Peak performance observed during specific months  

###  Category Performance
- Revenue is highly concentrated in a few categories  
- Follows a **Pareto pattern (80/20 rule)**  

###  Geographic Insights
- Sales are concentrated in major urban regions  
- Indicates expansion opportunities in underperforming areas  

###  Returns Analysis
- Returns are **not evenly distributed**
- Certain regions show higher return risk  
- Suggests operational or product-level issues  

### Channel Performance
- Variation observed across channels  
- Opportunity for **channel optimization**

---

## Technologies Used
- **Snowflake** → Data warehouse  
- **SQL** → Data transformation & analytics  
- **Power BI** → Data visualization  
- **Kaggle Dataset** → Data source  

---

## 📁 Repository Structure
