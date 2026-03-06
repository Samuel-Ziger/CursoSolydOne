#!/bin/bash
# Script Único de Investigação Completa - Parte 1 CTF9
# Execute: bash investigacao_completa.sh
# Resultados serão salvos em investigacao_resultados.txt

OUTPUT_FILE="investigacao_resultados.txt"

echo "==========================================" > "$OUTPUT_FILE"
echo "INVESTIGAÇÃO COMPLETA - PARTE 1 CTF9" >> "$OUTPUT_FILE"
echo "Data: $(date)" >> "$OUTPUT_FILE"
echo "==========================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Iniciando investigação completa..."
echo "[*] Resultados serão salvos em: $OUTPUT_FILE"
echo ""

# ==========================================
# SEÇÃO 1: INFORMAÇÕES BÁSICAS E FLAGS
# ==========================================
echo "[1/5] Investigando flags e informações básicas..."
echo "" >> "$OUTPUT_FILE"
echo "==========================================" >> "$OUTPUT_FILE"
echo "SEÇÃO 1: FLAGS E INFORMAÇÕES BÁSICAS" >> "$OUTPUT_FILE"
echo "==========================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Usuário atual:" >> "$OUTPUT_FILE"
whoami >> "$OUTPUT_FILE"
id >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Lendo /flag.txt encontrado:" >> "$OUTPUT_FILE"
cat /flag.txt 2>/dev/null >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando se há outras flags:" >> "$OUTPUT_FILE"
find / -name "*flag*" -type f 2>/dev/null | grep -v proc | grep -v sys | head -20 >> "$OUTPUT_FILE"
find / -name "*Flag*" -type f 2>/dev/null | grep -v proc | grep -v sys | head -20 >> "$OUTPUT_FILE"
find / -name "*FLAG*" -type f 2>/dev/null | grep -v proc | grep -v sys | head -20 >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando diretório home do adalberto:" >> "$OUTPUT_FILE"
ls -la /home/adalberto/ >> "$OUTPUT_FILE"
cat /home/adalberto/flag.txt 2>/dev/null >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando diretório root:" >> "$OUTPUT_FILE"
ls -la /root/ 2>/dev/null | head -30 >> "$OUTPUT_FILE"
find /root -name "*flag*" -type f 2>/dev/null >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Buscando arquivos LightBringers:" >> "$OUTPUT_FILE"
find / -name "*LightBringers*" -o -name "*lightbringers*" -o -name "*LIGHTBRINGERS*" 2>/dev/null | grep -v proc | grep -v sys >> "$OUTPUT_FILE"
grep -r "LightBringers\|lightbringers\|LIGHTBRINGERS" /home /var/www /opt /tmp 2>/dev/null | head -30 >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Buscando arquivos solyd:" >> "$OUTPUT_FILE"
find / -name "*solyd*" -o -name "*Solyd*" -o -name "*SOLYD*" 2>/dev/null | grep -v proc | grep -v sys | head -20 >> "$OUTPUT_FILE"
grep -r "solyd\|Solyd\|SOLYD" /home /var/www /opt /tmp 2>/dev/null | head -30 >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# ==========================================
# SEÇÃO 2: REDE INTERNA
# ==========================================
echo "[2/5] Investigando rede interna..."
echo "" >> "$OUTPUT_FILE"
echo "==========================================" >> "$OUTPUT_FILE"
echo "SEÇÃO 2: REDE INTERNA" >> "$OUTPUT_FILE"
echo "==========================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Interfaces de rede:" >> "$OUTPUT_FILE"
ip a >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Rotas:" >> "$OUTPUT_FILE"
ip route >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] ARP cache:" >> "$OUTPUT_FILE"
arp -a >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Arquivo /etc/hosts:" >> "$OUTPUT_FILE"
cat /etc/hosts >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Arquivo /etc/resolv.conf:" >> "$OUTPUT_FILE"
cat /etc/resolv.conf >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Todas as conexões TCP/UDP:" >> "$OUTPUT_FILE"
ss -tulnp >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Conexões estabelecidas:" >> "$OUTPUT_FILE"
ss -antp | grep ESTABLISHED >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Conexões em escuta:" >> "$OUTPUT_FILE"
ss -antp | grep LISTEN >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Netstat alternativo:" >> "$OUTPUT_FILE"
netstat -antup 2>/dev/null >> "$OUTPUT_FILE" || echo "netstat não disponível" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Processos de rede:" >> "$OUTPUT_FILE"
ps aux | grep -E "ssh|socat|nc|netcat|tunnel|proxy" | grep -v grep >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando processos com lsof:" >> "$OUTPUT_FILE"
lsof -i 2>/dev/null | head -50 >> "$OUTPUT_FILE" || echo "lsof não disponível" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# ==========================================
# SEÇÃO 3: CHAVES SSH E CREDENCIAIS
# ==========================================
echo "[3/5] Buscando chaves SSH e credenciais..."
echo "" >> "$OUTPUT_FILE"
echo "==========================================" >> "$OUTPUT_FILE"
echo "SEÇÃO 3: CHAVES SSH E CREDENCIAIS" >> "$OUTPUT_FILE"
echo "==========================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Buscando chaves SSH (id_rsa, id_dsa, etc):" >> "$OUTPUT_FILE"
find / -name "id_rsa*" -o -name "id_dsa*" -o -name "id_ecdsa*" -o -name "id_ed25519*" 2>/dev/null | grep -v proc | grep -v sys >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Buscando arquivos .pem:" >> "$OUTPUT_FILE"
find / -name "*.pem" 2>/dev/null | grep -v proc | grep -v sys | head -20 >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando diretórios .ssh:" >> "$OUTPUT_FILE"
find / -type d -name ".ssh" 2>/dev/null | grep -v proc | grep -v sys >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Conteúdo de ~/.ssh:" >> "$OUTPUT_FILE"
ls -la ~/.ssh/ 2>/dev/null >> "$OUTPUT_FILE"
cat ~/.ssh/* 2>/dev/null >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Conteúdo de /home/*/.ssh:" >> "$OUTPUT_FILE"
for dir in /home/*/.ssh; do
    if [ -d "$dir" ]; then
        echo "=== $dir ===" >> "$OUTPUT_FILE"
        ls -la "$dir" 2>/dev/null >> "$OUTPUT_FILE"
        cat "$dir"/* 2>/dev/null >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

echo "[*] Conteúdo de /root/.ssh:" >> "$OUTPUT_FILE"
ls -la /root/.ssh/ 2>/dev/null >> "$OUTPUT_FILE"
cat /root/.ssh/* 2>/dev/null >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando known_hosts:" >> "$OUTPUT_FILE"
cat ~/.ssh/known_hosts 2>/dev/null >> "$OUTPUT_FILE"
cat /home/*/.ssh/known_hosts 2>/dev/null >> "$OUTPUT_FILE"
cat /root/.ssh/known_hosts 2>/dev/null >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando authorized_keys:" >> "$OUTPUT_FILE"
cat ~/.ssh/authorized_keys 2>/dev/null >> "$OUTPUT_FILE"
cat /home/*/.ssh/authorized_keys 2>/dev/null >> "$OUTPUT_FILE"
cat /root/.ssh/authorized_keys 2>/dev/null >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Buscando credenciais em arquivos de configuração:" >> "$OUTPUT_FILE"
grep -r "password\|passwd\|secret\|key\|credential" /var/www/blogo/config/ 2>/dev/null >> "$OUTPUT_FILE"
grep -r "password\|passwd\|secret\|key\|credential" /home/adalberto/ 2>/dev/null | grep -v ".cargo" | grep -v ".rustup" | head -30 >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# ==========================================
# SEÇÃO 4: MOVIMENTO LATERAL
# ==========================================
echo "[4/5] Investigando movimento lateral..."
echo "" >> "$OUTPUT_FILE"
echo "==========================================" >> "$OUTPUT_FILE"
echo "SEÇÃO 4: MOVIMENTO LATERAL" >> "$OUTPUT_FILE"
echo "==========================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando processos SSH ativos:" >> "$OUTPUT_FILE"
ps aux | grep ssh | grep -v grep >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando túneis e port forwarding:" >> "$OUTPUT_FILE"
ps aux | grep -E "socat|nc|netcat|tunnel|forward" | grep -v grep >> "$OUTPUT_FILE"
ss -antp | grep -E "ESTABLISHED|LISTEN" | grep -E "127\.|10\.|172\.|192\." >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando logs do sistema por conexões SSH:" >> "$OUTPUT_FILE"
grep -i ssh /var/log/auth.log 2>/dev/null | tail -30 >> "$OUTPUT_FILE"
grep -i ssh /var/log/syslog 2>/dev/null | tail -30 >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando arquivos recentemente modificados relacionados a rede:" >> "$OUTPUT_FILE"
find /home -type f -mtime -7 2>/dev/null | head -20 >> "$OUTPUT_FILE"
find /tmp -type f -mtime -1 2>/dev/null | head -20 >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando arquivos de configuração do MySQL para conexões remotas:" >> "$OUTPUT_FILE"
grep -i "bind\|host\|remote" /etc/mysql/*.cnf 2>/dev/null >> "$OUTPUT_FILE"
grep -i "bind\|host\|remote" /etc/mysql/*/*.cnf 2>/dev/null >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando se há scripts ou binários suspeitos:" >> "$OUTPUT_FILE"
find /tmp -type f -executable 2>/dev/null >> "$OUTPUT_FILE"
find /var/tmp -type f -executable 2>/dev/null >> "$OUTPUT_FILE"
ls -la /tmp/*.sh 2>/dev/null >> "$OUTPUT_FILE"
ls -la /tmp/socat* 2>/dev/null >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando cron jobs que possam fazer conexões:" >> "$OUTPUT_FILE"
cat /etc/crontab 2>/dev/null >> "$OUTPUT_FILE"
ls -la /etc/cron.* 2>/dev/null >> "$OUTPUT_FILE"
crontab -l 2>/dev/null >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando arquivos de configuração do Apache por proxies reversos:" >> "$OUTPUT_FILE"
grep -i -E "proxy|forward|remote" /etc/apache2/sites-enabled/* 2>/dev/null >> "$OUTPUT_FILE"
grep -i -E "proxy|forward|remote" /etc/apache2/conf-enabled/* 2>/dev/null >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# ==========================================
# SEÇÃO 5: HISTÓRICO E LOGS
# ==========================================
echo "[5/5] Analisando histórico e logs..."
echo "" >> "$OUTPUT_FILE"
echo "==========================================" >> "$OUTPUT_FILE"
echo "SEÇÃO 5: HISTÓRICO E LOGS" >> "$OUTPUT_FILE"
echo "==========================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Histórico bash completo:" >> "$OUTPUT_FILE"
cat ~/.bash_history 2>/dev/null >> "$OUTPUT_FILE"
cat /home/*/.bash_history 2>/dev/null >> "$OUTPUT_FILE"
cat /root/.bash_history 2>/dev/null >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Histórico procurando SSH:" >> "$OUTPUT_FILE"
cat ~/.bash_history 2>/dev/null | grep -i ssh >> "$OUTPUT_FILE"
cat /home/*/.bash_history 2>/dev/null | grep -i ssh >> "$OUTPUT_FILE"
cat /root/.bash_history 2>/dev/null | grep -i ssh >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Histórico procurando flags:" >> "$OUTPUT_FILE"
cat ~/.bash_history 2>/dev/null | grep -i flag >> "$OUTPUT_FILE"
cat /home/*/.bash_history 2>/dev/null | grep -i flag >> "$OUTPUT_FILE"
cat /root/.bash_history 2>/dev/null | grep -i flag >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando arquivos de log por menções a flags:" >> "$OUTPUT_FILE"
grep -i "flag\|solyd\|lightbringers" /var/log/*.log 2>/dev/null | tail -30 >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando diretórios web por flags:" >> "$OUTPUT_FILE"
find /var/www -name "*flag*" -type f 2>/dev/null >> "$OUTPUT_FILE"
grep -r "flag\|Flag\|FLAG" /var/www 2>/dev/null | grep -i "solyd" | head -20 >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "[*] Verificando diretórios de usuários por flags:" >> "$OUTPUT_FILE"
for user_dir in /home/*; do
    if [ -d "$user_dir" ]; then
        echo "=== $user_dir ===" >> "$OUTPUT_FILE"
        ls -la "$user_dir" | grep -i flag >> "$OUTPUT_FILE"
        find "$user_dir" -name "*flag*" -type f 2>/dev/null >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

echo "" >> "$OUTPUT_FILE"
echo "==========================================" >> "$OUTPUT_FILE"
echo "INVESTIGAÇÃO CONCLUÍDA" >> "$OUTPUT_FILE"
echo "Data: $(date)" >> "$OUTPUT_FILE"
echo "==========================================" >> "$OUTPUT_FILE"

echo ""
echo "=========================================="
echo "✅ INVESTIGAÇÃO COMPLETA CONCLUÍDA!"
echo "=========================================="
echo ""
echo "📄 Resultados salvos em: $OUTPUT_FILE"
echo ""
echo "Para visualizar os resultados:"
echo "  cat $OUTPUT_FILE"
echo ""
