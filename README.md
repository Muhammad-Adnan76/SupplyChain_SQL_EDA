# 🏭 Supply Chain SQL EDA

## 📌 Project Overview
This project demonstrates **Exploratory Data Analysis (EDA)** on a **Supply Chain Database** using **Microsoft SQL Server (T-SQL)**. The goal is to transform raw operational data into **actionable business insights** to improve supply chain visibility, efficiency, and profitability.

The project follows a **multi-layered data architecture**:

- **Bronze Layer:** Raw staging data (`Bronze.Stg_SupplyChainData`)  
- **Silver Layer:** Cleaned and transformed data (`Silver.Transform_SupplyChainData`)  
- **Gold Layer:** Aggregated analytical views (`Gold.VW_*`) for reporting  

---

## 🧱 Methodology

1. **Data Exploration**  
   - Count rows and examine schema for Bronze & Silver layers.  
   - Review column details, nullability, and data types.

2. **Dimensions Exploration**  
   - Analyze core dimensions: Products, Customers, Stores, Shipping, Orders.  
   - Identify unique categories, statuses, and customer locations.

3. **Date Range Exploration**  
   - Determine order and shipping timelines.  
   - Calculate shipping delays and operational duration.

4. **Measures Exploration (Key Metrics)**  
   - Total orders, revenue, profit, and average sales.  
   - Unique products sold, total product quantity, and customer counts.

5. **Magnitude Analysis**  
   - Highest discounts, top-selling products, and country-wise sales distribution.  
   - Category-wise revenue, average price, and customer revenue contributions.

6. **Ranking Analysis**  
   - Top 5 revenue-generating products & top 5 by quantity sold.  
   - Bottom 5 underperforming products.  
   - Top 10 customers by revenue and 3 customers with the fewest orders.

---

## 💡 Key Insights

- **Top 5 products** generate the majority of revenue.  
- **Shipping delays** impact regional performance.  
- **Category-wise profitability** highlights high-value areas.  
- **Customer lifetime value patterns** reveal retention opportunities.  

---

## 🛠️ Tools & Technologies

- Microsoft SQL Server (T-SQL)  
- CTEs, Window Functions, Aggregations for EDA  
- Views & Stored Procedures for reporting  
- Optional: Power BI / Excel for visualizations  
