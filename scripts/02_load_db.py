import pandas as pd
import sqlite3
import sys
from pathlib import Path

def main():
    repo_root = Path(__file__).resolve().parent.parent
    raw_dir = repo_root / 'data' / 'raw'
    db_path = repo_root / 'data' / 'olist.db'
    
    # Ensure data directory exists
    (repo_root / 'data').mkdir(parents=True, exist_ok=True)
    
    conn = sqlite3.connect(db_path)
    
    schema_info = [
        ("olist_orders_dataset.csv", "orders", 99441, []),
        ("olist_customers_dataset.csv", "customers", 99441, []),
        ("olist_order_items_dataset.csv", "order_items", 112650, ["price", "freight_value", "order_item_id"]),
        ("olist_order_payments_dataset.csv", "order_payments", 103886, ["payment_value"]),
        ("olist_order_reviews_dataset.csv", "order_reviews", 99224, ["review_score"]),
        ("olist_products_dataset.csv", "products", 32951, []),
        ("olist_sellers_dataset.csv", "sellers", 3095, []),
        ("olist_geolocation_dataset.csv", "geolocation", 1000163, []),
        ("product_category_name_translation.csv", "category_translation", 71, [])
    ]
    
    for filename, table, expected_count, numeric_cols in schema_info:
        file_path = raw_dir / filename
        df = pd.read_csv(file_path, dtype=str)
        
        for col in numeric_cols:
            if col in df.columns:
                df[col] = pd.to_numeric(df[col])
                
        if len(df) != expected_count:
            print(f"Error: Row count for {table} differs. Expected {expected_count}, got {len(df)}.")
            sys.exit(1)
            
        df.to_sql(table, conn, if_exists='replace', index=False)
        print(f"Loaded {table}: {len(df)} rows")
        
    sql_path = repo_root / 'sql' / '01_indexes.sql'
    with open(sql_path, 'r', encoding='utf-8') as f:
        conn.executescript(f.read())
        
    print("LOAD OK")
    
if __name__ == "__main__":
    main()
