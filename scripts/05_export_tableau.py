import pandas as pd
import sqlite3
import sys
from pathlib import Path

def main():
    repo_root = Path(__file__).resolve().parent.parent
    db_path = repo_root / 'data' / 'olist.db'
    tableau_dir = repo_root / 'tableau'
    outputs_dir = repo_root / 'outputs'
    
    tableau_dir.mkdir(parents=True, exist_ok=True)
    
    conn = sqlite3.connect(db_path)
    
    # 1. orders.csv
    orders_cols = [
        'order_id', 'customer_unique_id', 'customer_state', 'customer_city', 
        'purchase_date', 'purchase_month', 'delivered_date', 'estimated_date', 
        'delay_days', 'actual_days', 'promised_days', 'on_time_flag', 'is_late', 
        'delay_bucket', 'bucket_order', 'item_count', 'seller_count', 'items_value', 
        'freight_value', 'payment_value', 'primary_seller_id', 'primary_seller_state', 
        'category', 'review_score'
    ]
    df_orders = pd.read_sql_query(f"SELECT {', '.join(orders_cols)} FROM order_facts", conn)
    df_orders.to_csv(tableau_dir / 'orders.csv', index=False, encoding='utf-8')
    print(f"Wrote orders.csv with {len(df_orders)} rows")
    
    # 2. monthly.csv
    df_monthly = pd.read_csv(outputs_dir / 'q02_monthly_trend.csv')
    df_monthly.to_csv(tableau_dir / 'monthly.csv', index=False, encoding='utf-8')
    print(f"Wrote monthly.csv")
    
    # 3. states.csv
    state_lookup = {
        'AC': 'Acre', 'AL': 'Alagoas', 'AP': 'Amapá', 'AM': 'Amazonas', 
        'BA': 'Bahia', 'CE': 'Ceará', 'DF': 'Distrito Federal', 'ES': 'Espírito Santo', 
        'GO': 'Goiás', 'MA': 'Maranhão', 'MT': 'Mato Grosso', 'MS': 'Mato Grosso do Sul', 
        'MG': 'Minas Gerais', 'PA': 'Pará', 'PB': 'Paraíba', 'PR': 'Paraná', 
        'PE': 'Pernambuco', 'PI': 'Piauí', 'RJ': 'Rio de Janeiro', 'RN': 'Rio Grande do Norte', 
        'RS': 'Rio Grande do Sul', 'RO': 'Rondônia', 'RR': 'Roraima', 'SC': 'Santa Catarina', 
        'SP': 'São Paulo', 'SE': 'Sergipe', 'TO': 'Tocantins'
    }
    df_states = pd.read_csv(outputs_dir / 'q04_state_performance.csv')
    df_states['state_name'] = df_states['customer_state'].map(state_lookup)
    df_states.rename(columns={'customer_state': 'state_code'}, inplace=True)
    df_states.to_csv(tableau_dir / 'states.csv', index=False, encoding='utf-8')
    print(f"Wrote states.csv")
    
    # 4. sellers_top.csv
    df_sellers = pd.read_csv(outputs_dir / 'q06_worst_sellers_per_state.csv')
    df_sellers.to_csv(tableau_dir / 'sellers_top.csv', index=False, encoding='utf-8')
    print(f"Wrote sellers_top.csv")
    
    # 5. cohort.csv
    df_cohort_3 = pd.read_csv(outputs_dir / 'q09_repeat_cohort.csv')
    df_cohort_3['cohort_type'] = '3-bucket'
    
    df_cohort_bin = pd.read_csv(outputs_dir / 'q09b_repeat_binary.csv')
    df_cohort_bin['cohort_type'] = 'binary'
    # Map binary back to 3-bucket schema for Tableau appending if necessary
    df_cohort_bin['delay_bucket'] = df_cohort_bin['is_late'].map({0: 'On time', 1: 'Late (any)'})
    df_cohort_bin['bucket_order'] = df_cohort_bin['is_late'].map({0: 1, 1: 2})
    df_cohort_bin = df_cohort_bin.drop(columns=['is_late'])
    
    df_cohort = pd.concat([df_cohort_3, df_cohort_bin], ignore_index=True)
    df_cohort.to_csv(tableau_dir / 'cohort.csv', index=False, encoding='utf-8')
    print(f"Wrote cohort.csv")
    
    # 6. opportunity.csv
    df_opp = pd.read_csv(outputs_dir / 'q11_opportunity_ranking.csv')
    df_opp.to_csv(tableau_dir / 'opportunity.csv', index=False, encoding='utf-8')
    print(f"Wrote opportunity.csv")
    
    # Verify row count
    df_facts = pd.read_sql_query("SELECT COUNT(*) as c FROM order_facts", conn)
    if len(df_orders) != df_facts.iloc[0]['c']:
        print(f"Error: orders.csv row count ({len(df_orders)}) does not match order_facts ({df_facts.iloc[0]['c']})")
        sys.exit(1)
        
    print("EXPORT OK")

if __name__ == "__main__":
    main()
