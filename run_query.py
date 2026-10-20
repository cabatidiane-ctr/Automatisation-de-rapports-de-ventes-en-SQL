"""Exécute une requête SQL sur Chinook et affiche le résultat.
Usage : python -I run_query.py "SELECT ..."   ou   python -I run_query.py fichier.sql
"""
import sqlite3
import sys
from pathlib import Path

DB = Path(__file__).parent / "Chinook_Sqlite.sqlite"


def main():
    arg = sys.argv[1]
    sql = Path(arg).read_text(encoding="utf-8") if arg.endswith(".sql") else arg
    con = sqlite3.connect(DB)
    cur = con.execute(sql)
    cols = [d[0] for d in cur.description] if cur.description else []
    rows = cur.fetchall()
    if cols:
        print(" | ".join(cols))
        print("-" * 60)
    for r in rows[:50]:
        print(" | ".join(str(v) for v in r))
    print(f"({len(rows)} ligne(s))")


if __name__ == "__main__":
    main()
