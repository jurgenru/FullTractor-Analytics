import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

conn = psycopg2.connect(
    host="localhost", port=5433,
    dbname=os.getenv("POSTGRES_DB"),
    user=os.getenv("POSTGRES_USER"),
    password=os.getenv("POSTGRES_PASSWORD")
)
cur = conn.cursor()

TABLES = [
    ("raw.categories",  "categories.csv"),
    ("raw.users",       "users.csv"),
    ("raw.products",    "products.csv"),
    ("raw.orders",      "orders.csv"),
    ("raw.order_items", "order_items.csv"),
]

for table, filename in TABLES:
    with open(filename, "r", encoding="utf-8") as f:
        cur.copy_expert(f"copy {table} from stdin with (format csv, header true)", f)
    print(f"{table}: cargado")

conn.commit()
cur.close()
conn.close()