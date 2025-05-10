use Bakery
--------------------------SUBQURIES-----------------------------------------------------------------------------
--1. Fetch Customers Who Have Placed Orders
SELECT* FROM Customer
WHERE CustomerID IN(Select Distinct CustomerID from Orders);

--2. Get Product Details for Out-of-Stock Items
SELECT*FROM Product
WHERE ProductID IN(SELECT ProductID FROM StockProduct WHERE QuantityInStock=100);

--Retrieve the supplier details for a specific ingredient (e.g., "Flour")
SELECT* FROM Supplier
WHERE SupplierID IN(SELECT SupplierID FROM Ingredients WHERE Name='Flour');

--Find the most expensive product.
select*From Product
where Price=(select max(Price) from Product);

--List orders where the total price exceeds 100
select*from Orders
where OrderID IN(select OrderID from OrderDetails where TotalPrice>100);

--select Product with max Price
SELECT * FROM Product 
WHERE ProductID = (SELECT TOP 1 ProductID FROM Product ORDER BY Price DESC) AND Price = (SELECT MAX(Price) FROM Product);

--find average price
SELECT AVG(TotalPrice) AS AvgPrice 
FROM (SELECT TotalPrice FROM OrderDetails WHERE OrderDate > '2024-01-01') AS RecentOrders;

--find name WHO have bought Brownie
select Name from Customer
where CustomerID IN(select CustomerID from Orders where ProductPurchased IN(select ProductID from Product where ProductName='Brownie'));

--Ingredients Used in a Specific Product
select Name from Ingredients
where IngredientID IN(Select IngredientID from ProductIngredients where ProductID IN(select ProductID from Product where ProductName='Brownie'));
