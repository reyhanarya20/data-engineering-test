import pandas as pd
import glob
import os
from sqlalchemy import create_engine

DB_USER = "root"
DB_PASSWORD = "root"
DB_HOST = "127.0.0.1"
DB_PORT = "3306"
DB_NAME = "maju_jaya_dw"

DATA_FOLDER = r"C:\Users\ASUS\Learn-python\technical_test_data_engineer\data"

engine = create_engine(
    f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

files = glob.glob(os.path.join(DATA_FOLDER, "customer_addresses_*.csv"))

if not files:
    raise FileNotFoundError("Tidak ada file customer_addresses_*.csv di folder data")

latest_file = max(files, key=os.path.getctime)

df = pd.read_csv(latest_file, sep=",")

print("Columns before cleaning:", df.columns.tolist())
print(df.head())

df.columns = df.columns.str.strip().str.lower()

print("Columns after cleaning:", df.columns.tolist())

df.to_sql(name="customer_addresses_raw", con=engine, if_exists="append", index=False)

print(f"Berhasil ingest file: {latest_file}")
