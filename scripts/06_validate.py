import sqlite3
import sys
from pathlib import Path

def main():
    repo_root = Path(__file__).resolve().parent.parent
    db_path = repo_root / 'data' / 'olist.db'
    
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    
    # Hard checks
    c1 = conn.execute("SELECT COUNT(*) AS c FROM order_facts").fetchone()['c']
    c2 = conn.execute("SELECT COUNT(DISTINCT order_id) AS c FROM order_facts").fetchone()['c']
    
    if c1 != c2:
        print(f"FAIL: order_facts has duplicate order_id. Count: {c1}, Distinct: {c2}")
        sys.exit(1)
        
    if not (95000 <= c1 <= 96478):
        print(f"FAIL: order_facts row count {c1} is outside [95000, 96478]")
        sys.exit(1)
        
    min_actual = conn.execute("SELECT MIN(actual_days) AS c FROM order_facts").fetchone()['c']
    if min_actual < 0:
        print(f"FAIL: MIN(actual_days) = {min_actual} < 0")
        sys.exit(1)
        
    bucket_counts = conn.execute("SELECT SUM(orders) AS c FROM (SELECT COUNT(*) AS orders FROM order_facts GROUP BY delay_bucket)").fetchone()['c']
    if bucket_counts != c1:
        print(f"FAIL: Sum of bucket orders ({bucket_counts}) != total orders ({c1})")
        sys.exit(1)
        
    # Soft checks
    late_rate = conn.execute("SELECT 100.0 * SUM(is_late) / COUNT(*) AS c FROM order_facts").fetchone()['c']
    if not (6 <= late_rate <= 10):
        print(f"WARNING: Overall late rate {late_rate:.2f}% is outside [6%, 10%]")
        
    avg_rev = conn.execute("SELECT AVG(review_score) AS c FROM order_facts").fetchone()['c']
    if not (3.9 <= avg_rev <= 4.3):
        print(f"WARNING: Average review score {avg_rev:.2f} is outside [3.9, 4.3]")
        
    print("VALIDATION OK")
    
if __name__ == "__main__":
    main()
