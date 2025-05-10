create database Bakery
use Bakery

-- Create Customer Table
CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(25)
);
select * from Customer



-- Create Product Table
CREATE TABLE Product (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100),
    Price DECIMAL(10, 2)
);
select * from product

-- Create Supplier Table
CREATE TABLE Supplier (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100),
    ContactInfo VARCHAR(100),
    Address VARCHAR(100)
);
select * from Supplier

-- Create Order Table
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
	ProductPurchased INT,
	Qty INT,
    CustomerID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
	FOREIGN KEY (ProductPurchased) REFERENCES Product(ProductID)
);
select * from Orders


-- Create Order Details Table
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    OrderDate DATETIME,
    ProductID INT,
    TotalPrice DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
select * from OrderDetails

-- Create Ingredients Table
CREATE TABLE Ingredients (
    IngredientID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100),
    Description TEXT,
    Unit VARCHAR(50),
    SupplierID INT,
    FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID)
);
select * from Ingredients

ALTER TABLE Ingredients
ALTER COLUMN Description VARCHAR(MAX);

-- Create Product Ingredient Table
CREATE TABLE ProductIngredients (
    ProductIngredientID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    IngredientID INT,
    Quantity DECIMAL(10, 2),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (IngredientID) REFERENCES Ingredients(IngredientID)
);
select * from productIngredients

-- Create Productions Table
CREATE TABLE Productions (
    ProductionID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    ProductionDate DATETIME,
    BatchNumber VARCHAR(50),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
select * from Productions

-- Create Production Quantity Table
CREATE TABLE ProductionQuantity (
    ProductionID INT,
    QuantityProduced INT,
    FOREIGN KEY (ProductionID) REFERENCES Productions(ProductionID)
);
select * from ProductionQuantity

-- Create Stock Table for Finished Products
CREATE TABLE StockProduct (
    StockProductID INT IDENTITY(1,1) PRIMARY KEY, -- Added separate primary key
    ProductID INT,
    QuantityInStock INT,
    LastUpdated DATETIME,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

select * from StockProduct

-- Create Stock Table for Ingredients
CREATE TABLE StockIngredients (
    StockIngredientID INT IDENTITY(1,1) PRIMARY KEY, -- Added separate primary key
    IngredientID INT,
    QuantityInStock DECIMAL(10, 2),
    LastUpdated DATETIME,
    FOREIGN KEY (IngredientID) REFERENCES Ingredients(IngredientID)
);
select * from StockIngredients



-- Create OrderHistory Table
CREATE TABLE OrderHistory (
    OrderHistoryID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    OldTotalAmount DECIMAL(10, 2),
    NewTotalAmount DECIMAL(10, 2),
    ChangeDate DATETIME DEFAULT GETDATE(),
    ActionType VARCHAR(10),  -- 'INSERT', 'UPDATE', or 'DELETE'
    CustomerID INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);
select* from OrderHistory

-- Create Product History Table
CREATE TABLE ProductHistory (
    ProductHistoryID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    OldPrice DECIMAL(10, 2),
    NewPrice DECIMAL(10, 2),
    ChangeDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
select * from ProductHistory




























                                                                                                                                                           



	

