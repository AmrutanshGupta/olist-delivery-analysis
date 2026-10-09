import subprocess
import sys
import os
from pathlib import Path

def main():
    repo_root = Path(__file__).resolve().parent.parent
    raw_dir = repo_root / 'data' / 'raw'
    raw_dir.mkdir(parents=True, exist_ok=True)
    
    print("Downloading dataset...")
    try:
        subprocess.run(
            [
                'python', '-m', 'kaggle', 'datasets', 'download',
                '-d', 'olistbr/brazilian-ecommerce',
                '-p', str(raw_dir),
                '--unzip'
            ],
            check=True
        )
    except Exception as e:
        print(f"Error: {e}")
        print("Download manually from https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce, unzip into data/raw/, then continue.")
        sys.exit(1)

    expected_files = [
        "olist_orders_dataset.csv",
        "olist_customers_dataset.csv",
        "olist_order_items_dataset.csv",
        "olist_order_payments_dataset.csv",
        "olist_order_reviews_dataset.csv",
        "olist_products_dataset.csv",
        "olist_sellers_dataset.csv",
        "olist_geolocation_dataset.csv",
        "product_category_name_translation.csv"
    ]

    for f in expected_files:
        if not (raw_dir / f).exists():
            print(f"Missing expected file: {f}")
            print("Download manually from https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce, unzip into data/raw/, then continue.")
            sys.exit(1)

    print("All required files downloaded and verified.")

if __name__ == "__main__":
    main()
