use Commerce

Create or alter  view vTopSales
as
select top(1)* from [Sales].[Orders]
order by totalprice desc 
select * from vTopSales v
--------------------------------------------------------Best Seller Money wise
Create or alter  view vLessSeller
as
select top(1) with ties * from [Sales].[OrderDetails]
order by Quantity  
select  p.productID , p.productname,p.producttype,v.quantity from vLessSeller v
 join [cataloog].[Products] p on v.productID = p.productID
 ------------------------------------------------------------------Less Seller Per Units
 CREATE OR ALTER VIEW seller_has_top_target AS
SELECT SellerID, fullname
FROM (SELECT s.SellerID, s.FirstName + ' ' + s.LastName AS fullname,
SUM(o.TotalPrice) AS TotalSales, DENSE_RANK() OVER (ORDER BY SUM(o.TotalPrice) DESC) AS rn
    FROM [userr].[Sellers] s
    JOIN [Sales].[Orders] o ON s.SellerID = o.SellerID
    GROUP BY s.SellerID, s.FirstName, s.LastName
) AS ranked_sellers
WHERE rn = 1;
select * from seller_has_top_target
---------------------------------------------------------------------------------
create or alter view sellers_region
as
select s.FirstName+' '+s.LastName as 'saller full name' ,w.Location from [cataloog].[Warehouses] w join [Sales].[Orders] o on w.WarehouseID= o.WarehouseID
join [userr].[Sellers] s on s.SellerID =o.SellerID

select * from sellers_region
-----------------------------
create or alter view costumer_type
as
select r.RegistrationName as 'Registration Name', count(c.CustomerID) 'cousterm count'  from [userr].[Registrations] r join [userr].[Customers] c on r.RegistrationID = c.RegistrationID
group by r.RegistrationName
select * from costumer_type
-----------------------------------
CREATE VIEW vMonthlySales 
AS
SELECT DATENAME(MONTH, starttime) AS MonthName,
    MONTH(starttime) AS MonthNumber,
    SUM(Total) AS TotalSales
FROM [Sales].[Orders] o
  join [Sales].[Orderdetails] od on co.customerorderid = od.customerorderid
GROUP BY DATENAME(MONTH, starttime), MONTH(starttime)
select * from v_MonthlySales

CREATE VIEW  vSalesMonthv
AS
SELECT top(1)* from v_MonthlySales
select * from vSalesMonthv
---------------------------------------

select orderid ,DATEDIFF(YEAR,Birthdate ,GETDATE()) As customerAge , totalprice 
from [userr].[Customers] c
join [Sales].[CustomerOrders] co on c.customerid = co.customerid
join [Sales].[Orders] o on o.
Create or alter  view vTargetedCustomers
as
select top(1)* from [Sales].[OrderDetails]
order by Quantity  
select  p.productID , p.productname,p.producttype,v.quantity from vLessSeller v
 join [cataloog].[Products] p on v.productID = p.productID

 select *from [userr].[Registrations]
  select *from [Sales].[Orderdetails]
select *from [cataloog].[Categories]
select *from [Sales].[Orders]
select *from [cataloog].[Products]
select *from [Sales].[CustomerOrders]
select *from [cataloog].[Warehouses]
select *from [userr].[Registrations]
select *from [userr].[Customers]
select *from [userr].[CustomerLoyalty]
