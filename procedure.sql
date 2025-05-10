use Bakery
--Stored Procedures for Analytical Reports
--Report 1: Total Sales by Product
CREATE PROCEDURE GetTotalSalesByProduct
AS
BEGIN
    SELECT 
        p.ProductName,
        SUM(od.TotalPrice) AS TotalSales
    FROM OrderDetails od
    INNER JOIN Product p ON od.ProductID = p.ProductID
    GROUP BY p.ProductName
    ORDER BY TotalSales DESC;
END;
EXEC GetTotalSalesByProduct

--Report 2: Monthly Revenue
CREATE PROCEDURE GetMonthlyRevenue
AS
BEGIN
    SELECT 
        YEAR(od.OrderDate) AS Year,
        MONTH(od.OrderDate) AS Month,
        SUM(od.TotalPrice) AS Revenue
    FROM OrderDetails od
    GROUP BY YEAR(od.OrderDate), MONTH(od.OrderDate)
    ORDER BY Year, Month;
END;
EXEC GetMonthlyRevenue

--Report 3: Customer Purchase Summary
CREATE PROCEDURE GetCustomerPurchaseSummary
AS
BEGIN
    SELECT 
        c.Name AS CustomerName,
        COUNT(o.OrderID) AS TotalOrders,
        SUM(od.TotalPrice) AS TotalSpent
    FROM Customer c
    INNER JOIN Orders o ON c.CustomerID = o.CustomerID
    INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
    GROUP BY c.Name
    ORDER BY TotalSpent DESC;
END;
EXEC GetCustomerPurchaseSummary

--Report 4: Inventory Status
CREATE PROCEDURE GetInventoryStatus
AS
BEGIN
    SELECT 
        p.ProductName,
        sp.QuantityInStock
    FROM StockProduct sp
    INNER JOIN Product p ON sp.ProductID = p.ProductID
ORDER BY sp.QuantityInStock ASC;
END;


--Report 5: Supplier Contribution
CREATE PROCEDURE GetSupplierContribution
AS
BEGIN
    SELECT 
        s.Name AS SupplierName,
        COUNT(i.IngredientID) AS TotalIngredientsSupplied
    FROM Supplier s
    INNER JOIN Ingredients i ON s.SupplierID = i.SupplierID
    GROUP BY s.Name
    ORDER BY TotalIngredientsSupplied DESC;
END;
EXEC GetSupplierContribution




-------------------PARAMETRIC PROCEDURE-----------------------
--Insert into Customer

CREATE PROCEDURE InsertCustomer
    @Name VARCHAR(100),
    @Email VARCHAR(100),
    @Phone VARCHAR(25)
AS
BEGIN
    INSERT INTO Customer (Name, Email, Phone)
    VALUES (@Name, @Email, @Phone);
END;
EXEC InsertCustomer 'Saman Majeed','samanmajeed110@gmail.com','03276965165';
--CREATE PROCEDURE InsertProduct
CREATE PROCEDURE InsertProduct
	@ProductName varchar(100),
	@Price Decimal(10,2)
as
BEGIN
	INSERT INTO Product(ProductName,Price)
	VALUES(@ProductName,@Price)
END;
EXEC InsertProduct 'Chocolate','500';

--insert into order

CREATE PROCEDURE InsertOrder
	@ProductPurchased INT,
	@Qty INT,
    @CustomerID INT
as
BEGIN
	INSERT INTO Orders(ProductPurchased,Qty,CustomerID)
	values(@ProductPurchased,@Qty,@CustomerID)
end;
EXEC InsertOrder'9','4','24';

--Insert into OrderDetails
CREATE PROCEDURE InsertOrderDetails
	@OrderID INT,
    @OrderDate DATETIME,
    @ProductID INT,
    @TotalPrice DECIMAL(10, 2)
AS
BEGIN
	Insert into OrderDetails(OrderID,OrderDate,ProductID,TotalPrice)
	Values(@OrderID,@OrderDate,@ProductID,@TotalPrice)
end;
EXEC InsertOrderDetails'24','2024-12-22','20','40.0';

--Update customerS
CREATE PROCEDURE UpdateCustomers
	@CustomerID INT ,
    @Name VARCHAR(100),
    @Email VARCHAR(100),
    @Phone VARCHAR(25)
AS
BEGIN 
	UPDATE Customer
	SET Name=@Name, Email=@Email, Phone=@Phone
	Where CustomerID=1;
end;
Exec UpdateCustomers'1','Sam','sam@email.com','12345678901';

--Update Product Price (with History)
CREATE PROCEDURE UpdateProductPrice
	 @ProductID INT,
     @NewPrice DECIMAL(10, 2)
AS
BEGIN
	DECLARE @OldPrice DeCIMAL(10, 2);
	SELECT @OldPrice=Price from Product where ProductID=@ProductID;

	UPDATE Product
	SET Price=@NewPrice
	where ProductID=@ProductID
	INSERT INTO ProductHistory (ProductID, OldPrice, NewPrice)
    VALUES (@ProductID, @OldPrice, @NewPrice);
END;
EXEC UpdateProductPrice '1','30.0';

--Update stock Product

CREATE PROCEDURE UpdateStockProduct
	--@StockProductID INT,
    @ProductID INT,
    @QuantityInStock INT,
    @LastUpdated DATETIME
AS
BEGIN
	UPDATE StockProduct
	SET ProductID=@ProductID,QuantityInStock=@QuantityInStock,LastUpdated=@LastUpdated
	where StockProductID=1
end;
EXEC UpdateStockProduct'1','70','2024-12-22';


--update Stock ingredient
Create procedure UpdateStockIngredients
	@StockIngredientID INT,
    @IngredientID INT,
    @QuantityInStock DECIMAL(10, 2),
    @LastUpdated DATETIME
AS
BEGIN
	update StockIngredients
	Set IngredientID=@IngredientID,QuantityInStock=@QuantityInStock,LastUpdated=@LastUpdated
	where StockIngredientID=@StockIngredientID

end;
Exec UpdateStockIngredients'1','1','10.0','2024-10-10';

--Delete Customer
CREATE PROCEDURE DeleteCustomer1
	@CustomerID int
as
begin
	delete from Customer where CustomerID=@CustomerID
end;
Exec DeleteCustomer1'204';

--delete Product
create procedure DeleteProduct
	@ProductID int
AS
BEGIN
	delete from Product where ProductID=@ProductID
end;
Exec DeleteProduct'32';

--RETRIEVE PROCEDURE
--GET ALL CUSTOMER
CREATE PROCEDURE GetAllCustomer
as
begin
	select*from Customer
end;
Exec GetAllCustomer;

--Get Products by Supplier
CREATE PROCEDURE GetProductBySupplier
	@SupplierID int
AS
BEGIN
	select p.ProductID,p.ProductName,pi.Quantity
	from Product p
	join ProductIngredients pi on p.ProductID=pi.ProductID
	where pi.ProductIngredientID IN(SELECT IngredientID from Ingredients where SupplierID=@SupplierID );
end;

EXEC GetProductBySupplier '1';

--Get order detail by customer
Create procedure GetOrderDetailByCustomers4
	@CustomerID int
as
begin
	select o.OrderID,od.OrderDate,od.ProductID,od.TotalPrice
	from Orders o
	join OrderDetails od on od.OrderID=o.orderID
	WHERE CustomerID =@CustomerID;
end;

EXEC GetOrderDetailByCustomers4'22';


--Insert into OrderHistory (on Update)
create procedure AddOrderHistory
	@OrderID INT,
    @OldTotalAmount DECIMAL(10, 2),
    @NewTotalAmount DECIMAL(10, 2),
    @ActionType VARCHAR(10),
    @CustomerID INT
as
begin
	insert into OrderHistory(OrderID,OldTotalAmount,NewTotalAmount,ActionType,CustomerID)
	values(@OrderID,@OldTotalAmount,@NewTotalAmount,@ActionType,@CustomerID)
end;
EXEC AddOrderHistory'1','10.0','20.0','Insert','1';


--delete from order HISTORY
CREATE PROCEDURE DeleteOrderHistory
as
begin
	delete from OrderHistory where OrderHistoryID=1002;
end;
exec DeleteOrderHistory

---------------------------------------------------------------------------
--------------------Non-Parametric Procedure-------------------------------
----GetTop5ProductsWithStock--------
create procedure GetTop5ProductsWithStock
as
begin
	select top 5
		p.ProductID,
		p.ProductName,
		sp.StockProductID,
		sp.QuantityInStock ,
        sp.LastUpdated
	from Product p
	join StockProduct sp on p.ProductID=sp.ProductID
end;
exec GetTop5ProductsWithStock

--------InsertDefaultProduct--------
create Procedure InsertDefaultProduct
as
begin
	insert into Product(ProductName,Price)
	values('mango delight',200);
end
exec InsertDefaultProduct

-----------DeleteLowPricedProducts--------
Create Procedure DeleteLowPricedProducts2
as
begin
	delete from Product
	where Price=8.83;
end;
exec DeleteLowPricedProducts2

-------------UpdateProductPrices--------
create procedure UpdateProductPrices
as
begin
	update Product
	set Price=Price*1.2;
end;
exec UpdateProductPrices

--------------Combined Procedure for Insert, Delete, and Update--------
create Procedure ManageProduct3
as
Begin
	Insert into Product(ProductName,Price)
	values('chocolate bar','10');
	print('inserest succesful');

	update Product
	set Price=100
	where ProductID=1020;
	print('Updated Succesful');

end;
exec ManageProduct3



