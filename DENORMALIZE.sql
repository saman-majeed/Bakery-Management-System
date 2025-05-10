use Bakery
-------------------------denormalize table-----------------------------------------
CREATE TABLE DenormalizedOrderDetails1 (
    OrderID INT,
    OrderDate DATETIME,
    CustomerID INT,
    CustomerName VARCHAR(100),
    CustomerEmail VARCHAR(100),
    CustomerPhone VARCHAR(25),
    ProductID INT,
    ProductName VARCHAR(100),
    ProductPrice DECIMAL(10, 2),
    Quantity INT,
    TotalPrice DECIMAL(10, 2),
    IngredientID INT,
    IngredientName VARCHAR(100),
    IngredientDescription TEXT,
    IngredientUnit VARCHAR(50),
    SupplierID INT,
    SupplierName VARCHAR(100),
    SupplierContactInfo VARCHAR(100),
    SupplierAddress VARCHAR(100),
    BatchNumber VARCHAR(50),
    ProductionDate DATETIME,
    ProductionQuantity INT,
    StockProductQuantity INT,
    StockProductLastUpdated DATETIME
);

-- Insert data into the denormalized table
INSERT INTO DenormalizedOrderDetails1 (
    OrderID, OrderDate, CustomerID, CustomerName, CustomerEmail, CustomerPhone,
    ProductID, ProductName, ProductPrice, Quantity, TotalPrice,
    IngredientID, IngredientName, IngredientDescription, IngredientUnit,
    SupplierID, SupplierName, SupplierContactInfo, SupplierAddress,
    BatchNumber, ProductionDate, ProductionQuantity,
    StockProductQuantity, StockProductLastUpdated
)
SELECT 
    O.OrderID, 
    OD.OrderDate, 
    C.CustomerID, 
    C.Name AS CustomerName, 
    C.Email AS CustomerEmail, 
    C.Phone AS CustomerPhone,
    P.ProductID, 
    P.ProductName, 
    P.Price AS ProductPrice, 
    O.Qty AS Quantity, 
    O.Qty * P.Price AS TotalPrice,
    I.IngredientID, 
    I.Name AS IngredientName, 
    I.Description AS IngredientDescription, 
    I.Unit AS IngredientUnit,
    S.SupplierID, 
    S.Name AS SupplierName, 
    S.ContactInfo AS SupplierContactInfo, 
    S.Address AS SupplierAddress,
    PR.BatchNumber, 
    PR.ProductionDate, 
    PQ.QuantityProduced AS ProductionQuantity,
    SP.QuantityInStock AS StockProductQuantity, 
    SP.LastUpdated AS StockProductLastUpdated
FROM 
    Orders O
JOIN 
    Customer C ON O.CustomerID = C.CustomerID
JOIN 
    OrderDetails OD ON O.OrderID = OD.OrderID
JOIN 
    Product P ON OD.ProductID = P.ProductID
LEFT JOIN 
    ProductIngredients PI ON P.ProductID = PI.ProductID
LEFT JOIN 
    Ingredients I ON PI.IngredientID = I.IngredientID
LEFT JOIN 
    Supplier S ON I.SupplierID = S.SupplierID
LEFT JOIN 
    Productions PR ON P.ProductID = PR.ProductID
LEFT JOIN 
    ProductionQuantity PQ ON PR.ProductionID = PQ.ProductionID
LEFT JOIN 
    StockProduct SP ON P.ProductID = SP.ProductID;

	







	-----------------------------------------------------------INSERET,UPDATE,DELETE IN DENORMALIZE TABLE WITH HELP OF TRIGGER--------------------------------------------------
CREATE TRIGGER trg_UpdateDenormalized_OnOrders
ON Orders
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Handle INSERT
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO DenormalizedOrderDetails1 (
            OrderID, OrderDate, CustomerID, CustomerName, CustomerEmail, CustomerPhone,
            ProductID, ProductName, ProductPrice, Quantity, TotalPrice,
            IngredientID, IngredientName, IngredientDescription, IngredientUnit,
            SupplierID, SupplierName, SupplierContactInfo, SupplierAddress,
            BatchNumber, ProductionDate, ProductionQuantity,
            StockProductQuantity, StockProductLastUpdated
        )
        SELECT 
            O.OrderID, 
            OD.OrderDate, 
            C.CustomerID, 
            C.Name AS CustomerName, 
            C.Email AS CustomerEmail, 
            C.Phone AS CustomerPhone,
            P.ProductID, 
            P.ProductName, 
            P.Price AS ProductPrice, 
            O.Qty AS Quantity, 
            O.Qty * P.Price AS TotalPrice,
            I.IngredientID, 
            I.Name AS IngredientName, 
            I.Description AS IngredientDescription, 
            I.Unit AS IngredientUnit,
            S.SupplierID, 
            S.Name AS SupplierName, 
            S.ContactInfo AS SupplierContactInfo, 
            S.Address AS SupplierAddress,
            PR.BatchNumber, 
            PR.ProductionDate, 
            PQ.QuantityProduced AS ProductionQuantity,
            SP.QuantityInStock AS StockProductQuantity, 
            SP.LastUpdated AS StockProductLastUpdated
        FROM 
            inserted O
        JOIN 
            Customer C ON O.CustomerID = C.CustomerID
        JOIN 
            OrderDetails OD ON O.OrderID = OD.OrderID
        JOIN 
            Product P ON OD.ProductID = P.ProductID
        LEFT JOIN 
            ProductIngredients PI ON P.ProductID = PI.ProductID
        LEFT JOIN 
            Ingredients I ON PI.IngredientID = I.IngredientID
        LEFT JOIN 
            Supplier S ON I.SupplierID = S.SupplierID
        LEFT JOIN 
            Productions PR ON P.ProductID = PR.ProductID
        LEFT JOIN 
            ProductionQuantity PQ ON PR.ProductionID = PQ.ProductionID
        LEFT JOIN 
            StockProduct SP ON P.ProductID = SP.ProductID;
    END;

    -- Handle UPDATE
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        DELETE FROM DenormalizedOrderDetails1
        WHERE OrderID IN (SELECT OrderID FROM deleted);

        INSERT INTO DenormalizedOrderDetails1 (
            OrderID, OrderDate, CustomerID, CustomerName, CustomerEmail, CustomerPhone,
            ProductID, ProductName, ProductPrice, Quantity, TotalPrice,
            IngredientID, IngredientName, IngredientDescription, IngredientUnit,
            SupplierID, SupplierName, SupplierContactInfo, SupplierAddress,
            BatchNumber, ProductionDate, ProductionQuantity,
            StockProductQuantity, StockProductLastUpdated
        )
        SELECT 
            O.OrderID, 
            OD.OrderDate, 
            C.CustomerID, 
            C.Name AS CustomerName, 
            C.Email AS CustomerEmail, 
            C.Phone AS CustomerPhone,
            P.ProductID, 
            P.ProductName, 
            P.Price AS ProductPrice, 
            O.Qty AS Quantity, 
            O.Qty * P.Price AS TotalPrice,
            I.IngredientID, 
            I.Name AS IngredientName, 
            I.Description AS IngredientDescription, 
            I.Unit AS IngredientUnit,
            S.SupplierID, 
            S.Name AS SupplierName, 
            S.ContactInfo AS SupplierContactInfo, 
            S.Address AS SupplierAddress,
            PR.BatchNumber, 
            PR.ProductionDate, 
            PQ.QuantityProduced AS ProductionQuantity,
            SP.QuantityInStock AS StockProductQuantity, 
            SP.LastUpdated AS StockProductLastUpdated
        FROM 
            inserted O
        JOIN 
            Customer C ON O.CustomerID = C.CustomerID
        JOIN 
            OrderDetails OD ON O.OrderID = OD.OrderID
        JOIN 
            Product P ON OD.ProductID = P.ProductID
        LEFT JOIN 
            ProductIngredients PI ON P.ProductID = PI.ProductID
        LEFT JOIN 
            Ingredients I ON PI.IngredientID = I.IngredientID
        LEFT JOIN 
            Supplier S ON I.SupplierID = S.SupplierID
        LEFT JOIN 
            Productions PR ON P.ProductID = PR.ProductID
        LEFT JOIN 
            ProductionQuantity PQ ON PR.ProductionID = PQ.ProductionID
        LEFT JOIN 
            StockProduct SP ON P.ProductID = SP.ProductID;
    END;

    -- Handle DELETE
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        DELETE FROM DenormalizedOrderDetails1
        WHERE OrderID IN (SELECT OrderID FROM deleted);
    END;
END;
GO
