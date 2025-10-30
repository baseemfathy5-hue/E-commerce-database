-------------------------------------------------------------
-- Sequence · Ê·Ìœ √—ﬁ«„
CREATE SEQUENCE id_adiut
START WITH 1 
INCREMENT BY 1;
-------------------------------------------------------------
-- ÃœÊ·  ”ÃÌ· «· €ÌÌ—« 
CREATE TABLE auditprice
(
    auditid INT PRIMARY KEY DEFAULT (NEXT VALUE FOR id_adiut),
    productid INT,
    oldprice DECIMAL(10,2),
    newprice DECIMAL(10,2),
    changedby NVARCHAR(255),
    changeddate DATETIME
);
-- «·Âœ›:   »⁄ «·√”⁄«—
-------------------------------------------------------------
-- Trigger  ”ÃÌ·  €ÌÌ—«  «·”⁄—
CREATE OR ALTER TRIGGER tri_updateproductprice
ON [cataloog].[products]
AFTER UPDATE
AS
BEGIN
    IF UPDATE(price)
    BEGIN
        INSERT INTO auditprice (productid, oldprice, newprice, changedby, changeddate)
        SELECT d.productid,
               d.price AS oldprice,
               i.price AS newprice,
               SUSER_SNAME() AS changedby,
               GETDATE() AS changeddate
        FROM deleted d
        INNER JOIN inserted i ON d.productid = i.productid;
    END
END;
-------------------------------------------------------------
-- Trigger  ÕœÌÀ «·„Œ“Ê‰
CREATE OR ALTER TRIGGER trg_check_StockLevel
ON [Sales].[OrderDetails]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    BEGIN TRY
        UPDATE p
        SET p.StockLevel = p.StockLevel - ISNULL(i.Quantity,0) + ISNULL(d.Quantity,0)
        FROM [cataloog].[Products] p
        LEFT JOIN inserted i ON p.ProductID = i.ProductID
        LEFT JOIN deleted d ON p.ProductID = d.ProductID;
    END TRY
    BEGIN CATCH
        PRINT 'Out Of Stock: ' + ERROR_MESSAGE();
    END CATCH
END;
-------------------------------------------------------------
