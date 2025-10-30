-- ≈‰‘«¡ ÿ·» ﬂ«„· ··⁄„Ì· (Full Order)
CREATE OR ALTER PROCEDURE dbo.SP_Create_Full_Order
    @CustomerID INT,
    @SellerID INT,
    @OrderYear INT,
    @OrderType VARCHAR(20),
    @RegistrationID INT,
    @WarehouseID INT,
    @StartTime DATETIME,
    @EndTime DATETIME,
    @SpecialOptions VARCHAR(255),
    @ProductID INT,
    @Quantity INT,
    @Fulfilled BIT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @CategoryID INT;
        DECLARE @SubcategoryID INT;
        DECLARE @price decimal(12,2);
        SELECT 
            @CategoryID = p.CategoryID,
            @SubcategoryID = s.SubcategoryID,
            @price = p.Price
        FROM [cataloog].[Products] p 
        JOIN [cataloog].[Categories] c ON p.CategoryID = c.CategoryID
        JOIN [cataloog].[Subcategories] s ON s.CategoryID = c.CategoryID
        WHERE p.ProductID = @ProductID;
        DECLARE @NewOrderID INT;
        INSERT INTO [Sales].[Orders]
            (CategoryID, SellerID, OrderYear, OrderType, RegistrationID, WarehouseID, 
            SubcategoryID, StartTime, EndTime, SpecialOptions)
        VALUES
            (@CategoryID, @SellerID, @OrderYear, @OrderType, @RegistrationID, 
            @WarehouseID, @SubcategoryID, @StartTime, @EndTime, @SpecialOptions);
        SET @NewOrderID = SCOPE_IDENTITY();
        DECLARE @NewCustomerOrderID INT;
        INSERT INTO [Sales].[CustomerOrders]
            (CustomerID, OrderID, FulfillmentDate, StartTime, EndTime)
        VALUES
            (@CustomerID, @NewOrderID, GETDATE(), @StartTime, @EndTime);
        SET @NewCustomerOrderID = SCOPE_IDENTITY();
        INSERT INTO [Sales].[OrderItems] (OrderID, ProductID)
        SELECT @NewOrderID, @ProductID
        FROM [cataloog].[Products] AS p
        WHERE p.ProductID = @ProductID;
        IF NOT EXISTS (
            SELECT 1 FROM [Sales].[OrderDetails]
            WHERE CustomerOrderID = @NewCustomerOrderID
              AND ProductID = @ProductID
        )
        BEGIN
            INSERT INTO [Sales].[OrderDetails]
                (CustomerOrderID, ProductID, Quantity, Fulfilled)
            VALUES
                (@NewCustomerOrderID, @ProductID, @Quantity, @Fulfilled);
        END
        ELSE
        BEGIN
            RAISERROR('This product already exists in the order.', 16, 1);
        END
        COMMIT TRANSACTION;
        PRINT 'Full Order Created Successfully.';

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error Creating Order: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
-------------------------------------------------------------
--  ≈÷«›… ⁄„Ì· ÃœÌœ
CREATE OR ALTER PROC dbo.addnewcustomer(
    @fname varchar(50),
    @lname varchar(50),
    @mail varchar(100),
    @regist int 
)
AS
BEGIN
    -- Â–« SP Ì÷Ì› ⁄„Ì· ÃœÌœ »«”„ Ê·ﬁ» Ê»—Ìœ ≈·ﬂ —Ê‰Ì Ê—ﬁ„  ”ÃÌ·
    INSERT INTO [userr].[Customers](FirstName, LastName, Email, RegistrationID)
    VALUES (@fname, @lname, @mail, @regist)
END;
GO
-------------------------------------------------------------
--  ID«·»ÕÀ ⁄‰ „‰ Ã«  »«·«”„ √Ê 
CREATE OR ALTER PROCEDURE dbo.searchproductsbynameorid (
    @searchterm nvarchar(100), 
    @productid int = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        productid,
        productname,
        producttype,
        stocklevel,
        variants,
        categoryid
    FROM [cataloog].[products]
    WHERE LOWER(productname) LIKE '%' + LOWER(@searchterm) + '%'
       OR productid = @productid
END;
GO

-------------------------------------------------------------
--   ÕœÌÀ «·√”⁄«— Õ”» «·›∆« 
CREATE OR ALTER PROCEDURE Update_Prices_by_categories
AS
BEGIN
    DECLARE update_price CURSOR FOR 
    SELECT p.ProductID, c.CategoryID
    FROM [cataloog].[Categories] c
    JOIN [cataloog].[Products] p ON c.CategoryID = p.CategoryID
    FOR UPDATE;
    OPEN update_price;
    DECLARE @ProductID int, @CategoryID int;
    FETCH update_price INTO @ProductID, @CategoryID;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @CategoryID IN (1,2,3)
            UPDATE [cataloog].[Products] SET Price = Price * 1.3 WHERE ProductID = @ProductID;
        ELSE IF  @CategoryID IN (4,5,6)
            UPDATE [cataloog].[Products] SET Price = Price * 1.2 WHERE ProductID = @ProductID;
        ELSE
            UPDATE [cataloog].[Products] SET Price = Price * 1.1 WHERE ProductID = @ProductID;
        FETCH update_price INTO @ProductID, @CategoryID;
    END
    CLOSE update_price;
    DEALLOCATE update_price;
END;
GO

-------------------------------------------------------------
--  Pagination⁄—÷ «·ÿ·»«  „⁄ 
CREATE OR ALTER PROCEDURE sp_get_orders
    @skip int,
    @take int
AS
BEGIN
    SELECT *
    FROM [Sales].[Orders]
    ORDER BY RegistrationID ASC
    OFFSET @skip ROWS FETCH NEXT @take ROWS ONLY;
END;
GO
-------------------------------------------------------------
-- View: √€·Ï „‰ Ã ·ﬂ· ›∆…
CREATE OR ALTER VIEW high_price_category AS
SELECT * 
FROM (
    SELECT *, DENSE_RANK() OVER (PARTITION BY [CategoryID] ORDER BY [Price] DESC) AS rn
    FROM [cataloog].[Products]
) AS newtable
WHERE rn = 1;
GO
-------------------------------------------------------------
-- View: √›÷· „‰ Ã „»Ì⁄« ·ﬂ· ›∆…
CREATE OR ALTER VIEW high_Products_sales AS
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY [CategoryID] ORDER BY totalprice DESC) AS rn
    FROM [Sales].[Orders] o  
) AS newtable
WHERE rn = 1;
GO
-------------------------------------------------------------
-- View: «·„‰ Ã «·√ﬂÀ— „»Ì⁄« „‰ ÕÌÀ «·ﬂ„Ì…
CREATE OR ALTER VIEW vBestSeller AS
SELECT TOP(1) * 
FROM [Sales].[OrderDetails]
ORDER BY Quantity DESC;
GO
-------------------------------------------------------------
-- View: «·ÿ·» «·√⁄·Ï ﬁÌ„… „«·Ì…
CREATE OR ALTER VIEW vTopSales AS
SELECT TOP(1) * 
FROM [Sales].[Orders]
ORDER BY totalprice DESC;
GO
-------------------------------------------------------------
-- View: «·„‰ Ã «·√ﬁ· „»Ì⁄« „‰ ÕÌÀ «·ﬂ„Ì…
CREATE OR ALTER VIEW vLessSeller AS
SELECT TOP(1) WITH TIES * 
FROM [Sales].[OrderDetails]
ORDER BY Quantity;
GO
-------------------------------------------------------------
-- View: √›÷· »«∆⁄ Õ”» «·„»Ì⁄« 
CREATE OR ALTER VIEW seller_has_top_target AS
SELECT SellerID, fullname, TotalSales
FROM (
    SELECT s.SellerID,
           s.FirstName + ' ' + s.LastName AS fullname,
           SUM(o.TotalPrice) AS TotalSales,
           DENSE_RANK() OVER (ORDER BY SUM(o.TotalPrice) DESC) AS rn
    FROM [userr].[Sellers] s
    JOIN [Sales].[Orders] o ON s.SellerID = o.SellerID
    GROUP BY s.SellerID, s.FirstName, s.LastName
) AS ranked_sellers
WHERE rn = 1;
GO
-------------------------------------------------------------
-- View: »«∆⁄Ì‰ „⁄ „‰«ÿﬁÂ„
CREATE OR ALTER VIEW sellers_region AS
SELECT s.FirstName + ' ' + s.LastName AS 'saller full name', w.Location 
FROM [cataloog].[Warehouses] w 
JOIN [Sales].[Orders] o ON w.WarehouseID = o.WarehouseID
JOIN [userr].[Sellers] s ON s.SellerID = o.SellerID;
GO
-------------------------------------------------------------
-- View: ⁄œœ «·⁄„·«¡ ·ﬂ· ‰Ê⁄  ”ÃÌ·
CREATE OR ALTER VIEW customer_type AS
SELECT r.RegistrationName AS 'Registration Name', COUNT(c.CustomerID) AS 'customer_counts' 
FROM [userr].[Registrations] r 
JOIN [userr].[Customers] c ON r.RegistrationID = c.RegistrationID
GROUP BY r.RegistrationName;
GO
-------------------------------------------------------------
-- View: ‰ﬁ«ÿ «·Ê·«¡ ·ﬂ· ›∆… Êœ—Ã… «·⁄„·«¡
CREATE OR ALTER VIEW LoyaltyPointsByCategory AS
SELECT c.CategoryName, l.teir, SUM(l.TotalPoint) AS 'Total Point' 
FROM [cataloog].[Categories] c 
JOIN [userr].[CustomerLoyalty] l ON c.CategoryID = l.CategoryID
GROUP BY l.teir, c.CategoryName;
GO
-------------------------------------------------------------
-- Function: Õ”«» ⁄„— «·⁄„Ì·
CREATE OR ALTER FUNCTION CustomerAge (@id INT)
RETURNS INT
AS
BEGIN
    RETURN (
        SELECT YEAR(GETDATE()) - YEAR(BirthDate)
        FROM [userr].[Customers]
        WHERE CustomerID = @id
    );
END;
GO
-- ≈÷«›… ⁄„Êœ Age ›Ì ÃœÊ· Customers »«” Œœ«„ «·œ«·…
ALTER TABLE [userr].[Customers]
ADD Age AS dbo.CustomerAge(CustomerID);
GO
-------------------------------------------------------------
-- View: „ Ê”ÿ ⁄„— «·⁄„·«¡ ·ﬂ· ‰Ê⁄  ”ÃÌ·
CREATE OR ALTER VIEW avg_age_customer AS
SELECT AVG(c.age) AS 'Avarege Age', r.RegistrationName AS 'Registration Name' 
FROM [userr].[Customers] c 
JOIN [userr].[Registrations] r ON c.RegistrationID = r.RegistrationID
GROUP BY r.RegistrationName;
GO
