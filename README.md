🗄️ Supermarket Data Analytics Project
💡 Project Overview

This project demonstrates a data-driven analytics system for a local supermarket using SQL Server.

The project includes:

📝 Stored Procedures (SPs) for managing orders, customers, and products

📊 Views to analyze sales, top-selling and low-selling products, seller performance, and customer statistics

The focus is on extracting insights from raw sales data to support decision-making and reporting.

🎯 Key Benefits of the Database & Views

🏆 Identify top & low-selling products → Helps manage inventory and make marketing decisions

📈 Analyze seller performance → Recognize top performers and allocate resources effectively

👥 Customer insights → Track customer types, loyalty points, and average age

🌍 Category & region analysis → Understand which categories and regions generate the most sales or profit

🔄 Audit & stock control → Automatically track price changes and stock levels using Triggers

🛠️ Key SQL Components
📝 Stored Procedures
SP Name	Purpose
SP_Create_Full_Order	🛒 Create complete customer orders with details
addnewcustomer	👤 Add a new customer
searchproductsbynameorid	🔍 Search products by name or ID
Update_Prices_by_categories	💰 Update product prices based on category rules
sp_get_orders	📄 Retrieve orders with pagination
📊 Views
View Name	Purpose
high_price_category	💎 Shows the highest-priced product per category
high_Products_sales	🔝 Best-selling products per category
vBestSeller	🏅 Product with highest quantity sold
vTopSales	💵 Orders with highest total price
vLessSeller	⚠️ Product with lowest quantity sold
seller_has_top_target	🥇 Top seller by total sales
sellers_region	🌍 Sellers with their warehouse region
customer_type	👥 Count of customers by registration type
LoyaltyPointsByCategory	🎁 Total loyalty points per category
avg_age_customer	📆 Average age of customers per registration type
⚡ Triggers & Audit

💹 Track price changes automatically (tri_updateproductprice)

📦 Update stock levels after orders (trg_check_StockLevel)

📝 Maintain audit records for price changes

🚀 Key Takeaways

🧠 Better business decisions: Use Views to identify top/bottom performers, sales trends, and customer insights

🔄 Automation: Triggers reduce manual updates and errors

⚙️ Scalable: New SPs or Views can be added easily for further analysis

📊 Dashboard-ready: Data is structured for Excel, Power BI, or other visualization tools