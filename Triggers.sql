USE Bakery
----------------------TRIGGERS------------------------------------------
-- Trigger to log changes in Orders table (INSERT, UPDATE, DELETE)
CREATE TRIGGER trg_OrderHistory1
ON Orders
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert operation: log the new order data
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO OrderHistory (OrderID, OldTotalAmount, NewTotalAmount, ChangeDate, ActionType, CustomerID)
        SELECT 
            i.OrderID,
            NULL, 
            (i.Qty * p.Price), -- Calculate the total amount dynamically
            GETDATE(),
            'INSERT',
            i.CustomerID
        FROM inserted i
        JOIN Product p ON i.ProductPurchased = p.ProductID;
    END;

    -- Update operation: log the updated order data
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO OrderHistory (OrderID, OldTotalAmount, NewTotalAmount, ChangeDate, ActionType, CustomerID)
        SELECT 
            d.OrderID,
            (d.Qty * p.Price), -- Old total amount
            (i.Qty * p.Price), -- New total amount
            GETDATE(),
            'UPDATE',
            i.CustomerID
        FROM deleted d
        JOIN inserted i ON d.OrderID = i.OrderID
        JOIN Product p ON i.ProductPurchased = p.ProductID;
    END;

    -- Delete operation: log the deleted order data
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO OrderHistory (OrderID, OldTotalAmount, NewTotalAmount, ChangeDate, ActionType, CustomerID)
        SELECT 
            d.OrderID,
            (d.Qty * p.Price), -- Old total amount
            NULL, 
            GETDATE(),
            'DELETE',
            d.CustomerID
        FROM deleted d
        JOIN Product p ON d.ProductPurchased = p.ProductID;
    END;
END;
GO

-- Trigger to log price changes in Product table
CREATE TRIGGER trg_ProductHistory
ON Product
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert into ProductHistory table when price is updated
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO ProductHistory (ProductID, OldPrice, NewPrice, ChangeDate)
        SELECT 
            i.ProductID,
            d.Price, 
            i.Price, 
            GETDATE()
        FROM inserted i
        INNER JOIN deleted d ON i.ProductID = d.ProductID
        WHERE i.Price <> d.Price; 
    END
END;

--Trigger to Log Product Price Changes---
CREATE TRIGGER TR_PRICE_PRODUCTCHANGE
ON Product
AFTER UPDATE
as
begin
	insert into ProductHistory(ProductID,OldPrice,NewPrice,ChangeDate)
	select
	Inserted.ProductID,
	Deleted.Price as OldPrice,
	inserted.Price as NewPrice,
	GETDATE()
 from
	inserted 
join 
	deleted on Inserted.ProductID = deleted.ProductID;
end;

---Trigger to Log Order Amount Changes---------
create trigger OrderAmountChange
on Orders
after update
as
begin
	If update(Qty)
	Begin
	insert into OrderHistory( OrderID,OldTotalAmount,NewTotalAmount,ChangeDate,ActionType,  CustomerID)
	select
	inserted.OrderID,
	(deleted.Qty*(select price from Product where ProductID=deleted.ProductPurchased))as OldPrice,
	(inserted.Qty*(select price from Product where ProductID=deleted.ProductPurchased))as NewPrice,
	GETDATE(),
	'Update',
	inserted.CustomerID
from
	inserted
join 
	deleted on inserted.OrderID=deleted.OrderID
end
end;
--------Trigger to Automatically Update Stock for Products-------------------
CREATE TRIGGER TR_UpdateStock_OnOrder
ON Orders
AFTER INSERT
AS
BEGIN
    UPDATE StockProduct
    SET QuantityInStock = QuantityInStock - INSERTED.Qty
    FROM StockProduct
    INNER JOIN INSERTED ON StockProduct.ProductID = INSERTED.ProductPurchased;

    PRINT 'Stock updated for the ordered products.';
END;


 -------------Trigger for Orders Table: Logging Insert, Update, and Delete Actions
 CREATE TRIGGER TR_OrderAudit
ON Orders
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Log INSERT Actions
    IF EXISTS (SELECT 1 FROM INSERTED) AND NOT EXISTS (SELECT 1 FROM DELETED)
    BEGIN
        INSERT INTO OrderHistory (OrderID, OldTotalAmount, NewTotalAmount, ChangeDate, ActionType, CustomerID)
        SELECT 
            INSERTED.OrderID,
            NULL AS OldTotalAmount,
            INSERTED.Qty * (SELECT Price FROM Product WHERE ProductID = INSERTED.ProductPurchased) AS NewTotalAmount,
            GETDATE(),
            'INSERT',
            INSERTED.CustomerID
        FROM INSERTED;
    END;

    -- Log UPDATE Actions
    IF EXISTS (SELECT 1 FROM INSERTED) AND EXISTS (SELECT 1 FROM DELETED)
    BEGIN
        INSERT INTO OrderHistory (OrderID, OldTotalAmount, NewTotalAmount, ChangeDate, ActionType, CustomerID)
        SELECT 
            DELETED.OrderID,
            DELETED.Qty * (SELECT Price FROM Product WHERE ProductID = DELETED.ProductPurchased) AS OldTotalAmount,
            INSERTED.Qty * (SELECT Price FROM Product WHERE ProductID = INSERTED.ProductPurchased) AS NewTotalAmount,
            GETDATE(),
            'UPDATE',
            INSERTED.CustomerID
        FROM INSERTED
        JOIN DELETED ON INSERTED.OrderID = DELETED.OrderID;
    END;

    -- Log DELETE Actions
    IF EXISTS (SELECT 1 FROM DELETED) AND NOT EXISTS (SELECT 1 FROM INSERTED)
    BEGIN
        INSERT INTO OrderHistory (OrderID, OldTotalAmount, NewTotalAmount, ChangeDate, ActionType, CustomerID)
        SELECT 
            DELETED.OrderID,
            DELETED.Qty * (SELECT Price FROM Product WHERE ProductID = DELETED.ProductPurchased) AS OldTotalAmount,
            NULL AS NewTotalAmount,
            GETDATE(),
            'DELETE',
            DELETED.CustomerID
        FROM DELETED;
    END;
END;
----create Audit table for cumstomer--------------
--------------BackupTable------
--Audit Table
CREATE TABLE AuditLog (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    ActionType VARCHAR(10),  
    TableName VARCHAR(100),
    RecordID INT,  
    OldValue varchar(20),  
    NewValue varchar(20),  
    ActionTime DATETIME DEFAULT GETDATE(),
    UserName VARCHAR(100),  
);
select * from AuditLog

--Trigger for audit table
CREATE TRIGGER trgAfterUpdate
ON Customer
FOR UPDATE
AS
BEGIN
    DECLARE @OldName VARCHAR(100), @NewName VARCHAR(100);
    
    SELECT @OldName = Name FROM deleted;
    SELECT @NewName = Name FROM inserted;
    
    INSERT INTO AuditLog (ActionType, TableName, RecordID, OldValue, NewValue, ActionTime, UserName)
    VALUES ('UPDATE', 'Customer', (SELECT customerID FROM inserted), @OldName, @NewName, GETDATE(), SYSTEM_USER);
END;

Update Customer
set Name='saman'
where CustomerID='1';





