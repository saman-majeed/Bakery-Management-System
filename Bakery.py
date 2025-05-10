import pyodbc
from faker import Faker
import random
from datetime import datetime, timedelta
import string

conn = pyodbc.connect(
    r'DRIVER={ODBC Driver 17 for SQL Server};'
    r'SERVER=DESKTOP-6DN2HMS\SQLEXPRESS;'
    r'DATABASE=Bakery;'
    r'Trusted_Connection=yes;'
)
# Connect to the database
cursor = conn.cursor()

fake = Faker()
# Function to insert fake data into the Customer table
def insert_customers(num_records):
    for _ in range(num_records):
        name = fake.name()
        email = fake.email()
        phone = fake.phone_number()
        
        cursor.execute('''
            INSERT INTO Customer (Name, Email, Phone)
            VALUES (?, ?, ?)
        ''', (name, email, phone))
    conn.commit()

# Function to insert fake data into the Supplier table
def insert_suppliers(num_records):
    for _ in range(num_records):
        name = fake.company()
        contact_info = fake.phone_number()
        address = fake.address()
        
        cursor.execute('''
            INSERT INTO Supplier (Name, ContactInfo, Address)
            VALUES (?, ?, ?)
        ''', (name, contact_info, address))
    conn.commit()

bakery_products = [
    "White Bread", "Whole Wheat Bread", "Sourdough Bread", "Rye Bread", "Baguette",
    "Croissant", "Danish Pastry", "Cinnamon Roll", "Muffin", "Cupcake",
    "Chocolate Chip Cookie", "Oatmeal Raisin Cookie", "Sugar Cookie", "Brownie", "Macaron",
    "Eclair", "Cream Puff", "Donut", "Apple Pie", "Blueberry Pie",
    "Cheesecake", "Pound Cake", "Fruit Tart", "Lemon Bar", "Baklava",
    "Pita Bread", "Bagel", "Focaccia", "Brioche", "Pretzel"
]

# Function to insert fake data into the Product table
def insert_products(num_records):
    for _ in range(num_records):
        product_name = random.choice(bakery_products)
        price = round(random.uniform(5.0, 50.0), 2)
        
        cursor.execute('''
            INSERT INTO Product (ProductName, Price)
            VALUES (?, ?)
        ''', (product_name, price))
    conn.commit()

ingredients = [
    {"name": "Flour", "description": "A powdery ingredient made from grains, used as a base for baking."},
    {"name": "Sugar", "description": "A sweet crystalline substance used to add sweetness to recipes."},
    {"name": "Butter", "description": "A creamy dairy product used to add richness and flavor."},
    {"name": "Yeast", "description": "A microorganism used to leaven bread and other baked goods."},
    {"name": "Salt", "description": "A mineral used to enhance flavor and control fermentation."},
    {"name": "Eggs", "description": "A versatile ingredient that adds structure, moisture, and richness."},
    {"name": "Milk", "description": "A dairy liquid that adds moisture and richness to baked goods."},
    {"name": "Vanilla Extract", "description": "A flavoring derived from vanilla beans, used for aroma and taste."},
    {"name": "Baking Powder", "description": "A chemical leavening agent used to make baked goods rise."},
    {"name": "Baking Soda", "description": "A leavening agent that reacts with acids to produce bubbles."},
    {"name": "Cocoa Powder", "description": "A powdered form of chocolate used in baking and desserts."},
    {"name": "Chocolate Chips", "description": "Small pieces of chocolate used in cookies and other treats."},
    {"name": "Cinnamon", "description": "A spice made from tree bark, used for warmth and flavor."},
    {"name": "Honey", "description": "A natural sweetener made by bees from flower nectar."},
    {"name": "Raisins", "description": "Dried grapes used for natural sweetness and texture."},
    {"name": "Almond Flour", "description": "A fine flour made from ground almonds, often used in gluten-free baking."},
    {"name": "Cream Cheese", "description": "A soft, creamy cheese used in desserts like cheesecake."},
    {"name": "Apples", "description": "A sweet and tart fruit used in pies and other desserts."},
    {"name": "Blueberries", "description": "Small, sweet berries often used in muffins and pies."},
    {"name": "Lemon Juice", "description": "A tangy citrus juice used for flavor and as a natural preservative."},
    {"name": "Cornstarch", "description": "A fine powder used as a thickening agent in sauces and fillings."},
    {"name": "Phyllo Dough", "description": "Thin sheets of dough used for pastries like baklava."},
    {"name": "Olive Oil", "description": "A flavorful oil used in breads like focaccia."},
    {"name": "Rosemary", "description": "A fragrant herb often used to flavor breads and savory pastries."},
    {"name": "Powdered Sugar", "description": "A fine sugar used for icings and dusting desserts."},
    {"name": "Nuts", "description": "Crunchy additions like almonds, walnuts, or pecans used for texture."},
    {"name": "Cream", "description": "A dairy product used for richness in fillings and toppings."},
    {"name": "Food Coloring", "description": "Liquid or gel colors used to tint icings and batters."},
    {"name": "Caraway Seeds", "description": "A spice often used in rye bread for added flavor."},
    {"name": "Water", "description": "A basic liquid ingredient used for hydration in doughs and batters."}
]

# Function to insert fake data into the Ingredients table
def insert_ingredients():
    supplier_ids = [row[0] for row in cursor.execute('SELECT SupplierID FROM Supplier')]

    for ingredient in ingredients:
        name = ingredient["name"]
        description = ingredient["description"]
        unit = random.choice(['kg', 'g', 'liter', 'ml'])
        supplier_id = random.choice(supplier_ids)

        cursor.execute('''
            INSERT INTO Ingredients (Name, Description, Unit, SupplierID)
            VALUES (?, ?, ?, ?)
        ''', (name, description, unit, supplier_id))
    
    conn.commit()

def insert_orders(num_records):
    customer_ids = [row[0] for row in cursor.execute('SELECT CustomerID FROM Customer')]
    product_id = [row[0] for row in cursor.execute('SELECT ProductID FROM Product')]

    for _ in range(num_records):
        customer_id = random.choice(customer_ids)
        product_purchased = random.choice(product_id)  # Select a random product
        qty = random.randint(1, 5)  # Random quantity between 1 and 10

        cursor.execute('''
            INSERT INTO Orders (ProductPurchased, Qty, CustomerID)
            VALUES (?, ?, ?)
        ''', (product_purchased, qty, customer_id))
    
    conn.commit()

# Function to insert fake data into the OrderDetails table
def insert_order_details():
    order_data = [(row[0], row[1], row[2]) for row in cursor.execute('SELECT OrderID, ProductPurchased, Qty FROM Orders')]
    product_prices = {row[0]: row[1] for row in cursor.execute('SELECT ProductID, Price FROM Product')}

    for order_id, product_id, qty in order_data:
        price_per_unit = product_prices[product_id]
        total_price = price_per_unit * qty  # Calculate the total price
        order_date = fake.date_this_year()

        cursor.execute('''
            INSERT INTO OrderDetails (OrderID, OrderDate, ProductID, TotalPrice)
            VALUES (?, ?, ?, ?)
        ''', (order_id, order_date, product_id, total_price))
    
    conn.commit()


# Function to insert fake data into the ProductIngredients table
def insert_product_ingredients(num_records):
    product_ids = [row[0] for row in cursor.execute('SELECT ProductID FROM Product')]
    ingredient_ids = [row[0] for row in cursor.execute('SELECT IngredientID FROM Ingredients')]
    for _ in range(num_records):
        product_id = random.choice(product_ids)
        ingredient_id = random.choice(ingredient_ids)
        quantity = round(random.uniform(0.1, 5.0), 2)
        
        cursor.execute('''
            INSERT INTO ProductIngredients (ProductID, IngredientID, Quantity)
            VALUES (?, ?, ?)
        ''', (product_id, ingredient_id, quantity))
    conn.commit()

# Function to insert fake data into the Productions table
def insert_productions(num_records):
    product_ids = [row[0] for row in cursor.execute('SELECT ProductID FROM Product')]
    for _ in range(num_records):
        product_id = random.choice(product_ids)
        production_date = fake.date_this_year()
        batch_number = fake.uuid4()
        
        cursor.execute('''
            INSERT INTO Productions (ProductID, ProductionDate, BatchNumber)
            VALUES (?, ?, ?)
        ''', (product_id, production_date, batch_number))
    conn.commit()

# Function to insert fake data into the ProductionQuantity table
def insert_production_quantities(num_records):
    production_ids = [row[0] for row in cursor.execute('SELECT ProductionID FROM Productions')]
    for _ in range(num_records):
        production_id = random.choice(production_ids)
        quantity_produced = random.randint(10, 200)
        
        cursor.execute('''
            INSERT INTO ProductionQuantity (ProductionID, QuantityProduced)
            VALUES (?, ?)
        ''', (production_id, quantity_produced))
    conn.commit()

# Function to insert fake data into the StockProduct table
def insert_stock_products(num_records):
    product_ids = [row[0] for row in cursor.execute('SELECT ProductID FROM Product')]
    for _ in range(num_records):
        product_id = random.choice(product_ids)
        quantity_in_stock = random.randint(10, 100)
        last_updated = datetime.now()
        
        cursor.execute('''
            INSERT INTO StockProduct (ProductID, QuantityInStock, LastUpdated)
            VALUES (?, ?, ?)
        ''', (product_id, quantity_in_stock, last_updated))
    conn.commit()

# Function to insert fake data into the StockIngredients table
def insert_stock_ingredients(num_records):
    ingredient_ids = [row[0] for row in cursor.execute('SELECT IngredientID FROM Ingredients')]
    for _ in range(num_records):
        ingredient_id = random.choice(ingredient_ids)
        quantity_in_stock = round(random.uniform(1.0, 100.0), 2)
        last_updated = datetime.now()
        
        cursor.execute('''
            INSERT INTO StockIngredients (IngredientID, QuantityInStock, LastUpdated)
            VALUES (?, ?, ?)
        ''', (ingredient_id, quantity_in_stock, last_updated))
    conn.commit()

# Function to insert fake data into the OrderHistory table
def insert_order_history(num_records):
    order_ids = [row[0] for row in cursor.execute('SELECT OrderID FROM Orders')]
    customer_ids = [row[0] for row in cursor.execute('SELECT CustomerID FROM Customer')]
    
    for _ in range(num_records):
        order_id = random.choice(order_ids)
        customer_id = random.choice(customer_ids)
        old_total_amount = round(random.uniform(10.0, 500.0), 2)
        new_total_amount = round(random.uniform(10.0, 500.0), 2)
        action_type = random.choice(['INSERT', 'UPDATE', 'DELETE'])
        
        cursor.execute('''
            INSERT INTO OrderHistory (OrderID, OldTotalAmount, NewTotalAmount, ChangeDate, ActionType, CustomerID)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (order_id, old_total_amount, new_total_amount, datetime.now(), action_type, customer_id))
    conn.commit()

# Function to insert fake data into the ProductHistory table
def insert_product_history(num_records):
    product_ids = [row[0] for row in cursor.execute('SELECT ProductID FROM Product')]
    for _ in range(num_records):
        product_id = random.choice(product_ids)
        old_price = round(random.uniform(5.0, 100.0), 2)
        new_price = round(random.uniform(5.0, 100.0), 2)
        
        cursor.execute('''
            INSERT INTO ProductHistory (ProductID, OldPrice, NewPrice, ChangeDate)
            VALUES (?, ?, ?, ?)
        ''', (product_id, old_price, new_price, datetime.now()))
    conn.commit()

# Main function to insert data into all tables
def insert_fake_data():
     insert_customers(100)
     insert_suppliers(5)
     insert_products(15)
     insert_orders(20)
     insert_order_details()
     insert_ingredients()
     insert_product_ingredients(30)
     insert_productions(10)
     insert_production_quantities(10)
     insert_stock_products(10)
     insert_stock_ingredients(10)
     insert_order_history(20)
     insert_product_history(10)
     print("Fake data inserted successfully.")

# Call the function to insert fake data
insert_fake_data()

# Close the connection
conn.close()