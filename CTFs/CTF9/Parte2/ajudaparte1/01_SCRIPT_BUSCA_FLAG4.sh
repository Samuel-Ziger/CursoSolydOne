#!/bin/bash
# Script Completo para Buscar Flag 4 - Parte 1
# Execute no servidor comprometido após estabelecer shell

echo "=========================================="
echo "BUSCA COMPLETA POR FLAG 4 - CTF9 PARTE 1"
echo "=========================================="
echo ""

# 1. BUSCA POR FLAGS
echo "[1/9] Buscando arquivos com 'flag' no nome..."
find / -name "*flag*" -type f 2>/dev/null | head -50
find / -name "*Flag*" -type f 2>/dev/null | head -50
find / -name "*FLAG*" -type f 2>/dev/null | head -50
echo ""

# 2. BUSCA POR LIGHTBRINGERS
echo "[2/9] Buscando arquivos LightBringers..."
find / -name "*LightBringers*" -o -name "*lightbringers*" 2>/dev/null | head -20
grep -r "LightBringers" /home /var/www /opt /tmp 2>/dev/null | head -20
grep -r "lightbringers" /home /var/www /opt /tmp 2>/dev/null | head -20
echo ""

# 3. BUSCA POR SOLYD NO CONTEÚDO
echo "[3/9] Buscando 'solyd' em arquivos..."
grep -r "solyd" /home /var/www /opt /tmp 2>/dev/null | grep -i flag | head -20
grep -r "Solyd" /home /var/www /opt /tmp 2>/dev/null | head -20
echo ""

# 4. REDE INTERNA
echo "[4/9] Investigando rede interna..."
echo "--- Interfaces de Rede ---"
ip a 2>/dev/null || ifconfig 2>/dev/null
echo ""
echo "--- Rotas ---"
ip route 2>/dev/null || route -n 2>/dev/null
echo ""
echo "--- ARP Cache ---"
arp -a 2>/dev/null || cat /proc/net/arp 2>/dev/null
echo ""

# 5. CONEXÕES ESTABELECIDAS
echo "[5/9] Verificando conexões estabelecidas..."
ss -antp 2>/dev/null | grep ESTABLISHED | head -20
netstat -antup 2>/dev/null | grep ESTABLISHED | head -20
lsof -i 2>/dev/null | head -20
echo ""

# 6. CHAVES SSH
echo "[6/9] Buscando chaves SSH..."
find / -name "id_rsa*" 2>/dev/null
find / -name "*.pem" 2>/dev/null
find / -name "*.key" 2>/dev/null
echo ""
echo "--- Known Hosts ---"
cat ~/.ssh/known_hosts 2>/dev/null
cat /home/*/.ssh/known_hosts 2>/dev/null
cat /root/.ssh/known_hosts 2>/dev/null
echo ""

# 7. HISTÓRICO DE COMANDOS
echo "[7/9] Verificando histórico de comandos..."
cat ~/.bash_history 2>/dev/null | tail -50
cat /home/*/.bash_history 2>/dev/null | tail -50
cat /root/.bash_history 2>/dev/null | tail -50
echo ""

# 8. PROCESSOS E TÚNEIS
echo "[8/9] Verificando processos suspeitos..."
ps aux | grep -E "ssh|socat|nc|tunnel" | grep -v grep
echo ""

# 9. DIRETÓRIOS ESPECÍFICOS
echo "[9/9] Verificando diretórios específicos..."
echo "--- /opt ---"
ls -la /opt/ 2>/dev/null
find /opt -name "*flag*" 2>/dev/null
echo ""
echo "--- /tmp ---"
ls -la /tmp/ 2>/dev/null | head -20
find /tmp -name "*flag*" 2>/dev/null
echo ""
echo "--- /var/log ---"
ls -la /var/log/ 2>/dev/null | head -20
grep -r "flag\|Flag\|FLAG" /var/log/ 2>/dev/null | head -10
echo ""

echo "=========================================="
echo "BUSCA CONCLUÍDA"
echo "=========================================="
