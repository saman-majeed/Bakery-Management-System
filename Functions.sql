use Bakery
	-----------------------------------------------------------------------------------------
	-------------------------function parametric-------------------------
--to calculate total price of an order

create function CalTotalPrice1(@OrderID INT)
Returns decimal(10,2)
as
begin
	declare @TotalPrice decimal(10,2);
	Select @TotalPrice=SUM(o.Qty*p.Price)
	from Product p
	join Orders o on p.ProductID=o.ProductPurchased
	where o.OrderID=@OrderID;

	Return @TotalPrice
end;
go
SELECT dbo.CalTotalPrice1(1) AS TotalPrice; 

--------------------non prametric--------------------------------

-----calculate total sale 
CREATE FUNCTION CalTotalSales()
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalSales DECIMAL(10, 2);

    -- Calculate the total sales by summing the prices of all products purchased in all orders
    SELECT @TotalSales = SUM(o.Qty * p.Price)
    FROM Product p
    JOIN Orders o ON p.ProductID = o.ProductPurchased;

-- Return the total sales value
 RETURN @TotalSales;
END;
GO
select dbo.CalTotalSales() as TotalSale;

