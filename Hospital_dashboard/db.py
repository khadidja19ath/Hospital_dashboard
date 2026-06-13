import sqlite3
import pandas as pd
import os

DB_PATH = os.path.join(os.path.dirname(__file__), "hospital.db")

def get_connection():
    return sqlite3.connect(DB_PATH)

def query(sql):
    conn = get_connection()
    df = pd.read_sql(sql, conn)
    conn.close()
    return df
