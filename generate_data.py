import csv, random
from datetime import datetime, timedelta

random.seed(42)  # mismos datos cada vez que corras

CATEGORIES = ["Tractors", "Harvesters", "Irrigation", "Tools", "Spare Parts"]
FIRST = ["Juan", "Maria", "Carlos", "Ana", "Luis", "Sofia", "Pedro", "Lucia"]
LAST = ["Perez", "Gomez", "Rojas", "Mamani", "Quispe", "Vargas", "Flores"]

# 1. categories
categories = [{"id": i, "name": n} for i, n in enumerate(CATEGORIES, start=1)]

# 2. users
users = [{"id": i,
          "name": random.choice(FIRST),
          "last_name": random.choice(LAST)}
         for i in range(1, 201)]

# 3. products
products = [{"id": i,
             "category_id": random.randint(1, len(categories)),
             "name": f"Product {i}",
             "stock": random.randint(0, 500),
             "price": round(random.uniform(50, 5000), 2)}
            for i in range(1, 51)]

# 4. orders + 5. order_items
orders, order_items = [], []
start = datetime(2024, 1, 1)
item_id = 1

for order_id in range(1, 5001):
    order_date = start + timedelta(days=random.randint(0, 730),
                                   hours=random.randint(0, 23))
    total = 0
    for _ in range(random.randint(1, 5)):
        p = random.choice(products)
        qty = random.randint(1, 4)
        historical_price = round(p["price"] * random.uniform(0.9, 1.1), 2)
        order_items.append({"id": item_id, "order_id": order_id,
                            "product_id": p["id"],
                            "historical_price": historical_price,
                            "quantity": qty})
        total += historical_price * qty
        item_id += 1
    orders.append({"id": order_id,
                   "user_id": random.randint(1, len(users)),
                   "total_price": round(total, 2),
                   "order_date": order_date.isoformat(sep=" ")})

def write_csv(filename, rows):
    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)
    print(f"{filename}: {len(rows)} filas")

write_csv("categories.csv", categories)
write_csv("users.csv", users)
write_csv("products.csv", products)
write_csv("orders.csv", orders)
write_csv("order_items.csv", order_items)