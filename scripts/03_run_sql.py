import sqlite3
import pandas as pd
import sys
from pathlib import Path

def main():
    repo_root = Path(__file__).resolve().parent.parent
    db_path = repo_root / 'data' / 'olist.db'
    sql_dir = repo_root / 'sql'
    analysis_dir = sql_dir / 'analysis'
    outputs_dir = repo_root / 'outputs'
    
    outputs_dir.mkdir(parents=True, exist_ok=True)
    
    conn = sqlite3.connect(db_path)
    
    # Run 02_views.sql
    views_path = sql_dir / '02_views.sql'
    print(f"Running {views_path.name}...")
    try:
        with open(views_path, 'r', encoding='utf-8') as f:
            conn.executescript(f.read())
    except Exception as e:
        print(f"Error in {views_path.name}: {e}")
        sys.exit(1)
        
    # Run analysis queries
    for sql_file in sorted(analysis_dir.glob('*.sql')):
        print(f"Running {sql_file.name}...")
        try:
            with open(sql_file, 'r', encoding='utf-8') as f:
                query = f.read()
                
            df = pd.read_sql_query(query, conn)
            out_name = sql_file.stem + '.csv'
            out_path = outputs_dir / out_name
            df.to_csv(out_path, index=False)
            print(f"Wrote {out_name} with {len(df)} rows")
            
        except Exception as e:
            print(f"Error in {sql_file.name}: {e}")
            sys.exit(1)
            
if __name__ == "__main__":
    main()
