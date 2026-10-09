set -e
python scripts/01_download.py
python scripts/02_load_db.py
python scripts/03_run_sql.py
python scripts/04_stats.py
python scripts/05_export_tableau.py
python scripts/06_validate.py
echo "ALL STEPS OK"
