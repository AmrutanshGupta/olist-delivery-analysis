import pandas as pd
import json
import math
from pathlib import Path

def main():
    repo_root = Path(__file__).resolve().parent.parent
    cohort_path = repo_root / 'outputs' / 'q09b_repeat_binary.csv'
    out_path = repo_root / 'outputs' / 'stats_summary.json'
    
    df = pd.read_csv(cohort_path)
    
    # 0 is on-time, 1 is late
    on_time = df[df['is_late'] == 0].iloc[0]
    late = df[df['is_late'] == 1].iloc[0]
    
    x1 = int(on_time['repeaters'])
    n1 = int(on_time['customers'])
    x2 = int(late['repeaters'])
    n2 = int(late['customers'])
    
    p1 = x1 / n1
    p2 = x2 / n2
    p1_pct = round(p1 * 100, 2)
    p2_pct = round(p2 * 100, 2)
    
    pooled_p = (x1 + x2) / (n1 + n2)
    se = math.sqrt(pooled_p * (1 - pooled_p) * (1/n1 + 1/n2))
    z = (p1 - p2) / se
    p_value = math.erfc(abs(z) / math.sqrt(2))
    
    unpooled_se = math.sqrt(p1 * (1 - p1) / n1 + p2 * (1 - p2) / n2)
    ci_low = (p1 - p2) - 1.96 * unpooled_se
    ci_high = (p1 - p2) + 1.96 * unpooled_se
    
    diff_pp = round((p1 - p2) * 100, 2)
    ci_low_pp = round(ci_low * 100, 2)
    ci_high_pp = round(ci_high * 100, 2)
    
    result = {
        "x1": x1,
        "n1": n1,
        "x2": x2,
        "n2": n2,
        "p1_pct": p1_pct,
        "p2_pct": p2_pct,
        "diff_pp": diff_pp,
        "ci_low_pp": ci_low_pp,
        "ci_high_pp": ci_high_pp,
        "z": round(z, 4),
        "p_value": p_value
    }
    
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2)
        
    print("Wrote stats_summary.json")

if __name__ == "__main__":
    main()
