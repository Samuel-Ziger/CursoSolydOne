#!/bin/bash

# Script para busca sistemática da Flag 4 - CTF9
# Baseado na análise do relatório existente

echo "=========================================="
echo "  BUSCA AUTOMATIZADA - FLAG 4 - CTF9"
echo "=========================================="
echo ""
echo "[+] Iniciando busca em $(date)"
echo ""

# Criar diretório de resultados
RESULT_DIR="/tmp/flag4_search_$(date +%s)"
mkdir -p "$RESULT_DIR"
echo "[+] Diretório de resultados: $RESULT_DIR"
echo ""

# Função para salvar resultados
save_result() {
    local file="$1"
    local content="$2"
    echo "$content" > "$RESULT_DIR/$file"
    echo "[+] Resultado salvo em: $RESULT_DIR/$file"
}

# ============================================
# PRIORIDADE ALTA 1: Arquivos do MySQL
# ============================================
echo "[PRIORIDADE ALTA] Explorando arquivos relacionados ao MySQL..."
echo ""

echo "[1.1] Verificando arquivos em /var/www/blogo/files/"
ls -la /var/www/blogo/files/ > "$RESULT_DIR/01_files_list.txt" 2>&1
cat "$RESULT_DIR/01_files_list.txt"

echo ""
echo "[1.2] Lendo settings.json..."
if [ -f /var/www/blogo/files/settings.json ]; then
    cat /var/www/blogo/files/settings.json > "$RESULT_DIR/02_settings_json.txt" 2>&1
    cat "$RESULT_DIR/02_settings_json.txt"
    echo ""
    echo "[!] Verificando se contém 'Solyd{' ou 'flag'..."
    grep -i "solyd\|flag" /var/www/blogo/files/settings.json 2>/dev/null || echo "Nenhuma flag encontrada"
else
    echo "[!] Arquivo settings.json não encontrado"
fi

echo ""
echo "[1.3] Lendo test.php..."
if [ -f /var/www/blogo/files/test.php ]; then
    cat /var/www/blogo/files/test.php > "$RESULT_DIR/03_test_php.txt" 2>&1
    cat "$RESULT_DIR/03_test_php.txt"
else
    echo "[!] Arquivo test.php não encontrado"
fi

echo ""
echo "[1.4] Lendo test.txt..."
if [ -f /var/www/blogo/files/test.txt ]; then
    cat /var/www/blogo/files/test.txt > "$RESULT_DIR/04_test_txt.txt" 2>&1
    cat "$RESULT_DIR/04_test_txt.txt"
else
    echo "[!] Arquivo test.txt não encontrado"
fi

echo ""
echo "[1.5] Verificando shell.php existente..."
if [ -f /var/www/blogo/shell.php ]; then
    cat /var/www/blogo/shell.php > "$RESULT_DIR/05_shell_php.txt" 2>&1
    echo "[+] Conteúdo salvo (verificar manualmente se necessário)"
else
    echo "[!] Arquivo shell.php não encontrado"
fi

echo ""
echo "[1.6] Verificando acesso ao diretório MySQL via grupo..."
ls -la /var/lib/mysql/ > "$RESULT_DIR/06_mysql_dir.txt" 2>&1
cat "$RESULT_DIR/06_mysql_dir.txt" | head -20

echo ""
echo "[1.7] Buscando arquivos do grupo mysql..."
find /var/lib/mysql -group mysql -type f 2>/dev/null > "$RESULT_DIR/07_mysql_group_files.txt"
if [ -s "$RESULT_DIR/07_mysql_group_files.txt" ]; then
    echo "[+] Arquivos encontrados:"
    cat "$RESULT_DIR/07_mysql_group_files.txt"
else
    echo "[!] Nenhum arquivo acessível via grupo mysql"
fi

# ============================================
# PRIORIDADE ALTA 2: Busca Sistemática de Flags
# ============================================
echo ""
echo "=========================================="
echo "[PRIORIDADE ALTA] Busca sistemática por flags..."
echo "=========================================="
echo ""

echo "[2.1] Buscando arquivos com nome 'flag'..."
find / -name "*flag*" -type f 2>/dev/null > "$RESULT_DIR/08_files_named_flag.txt"
if [ -s "$RESULT_DIR/08_files_named_flag.txt" ]; then
    echo "[+] Arquivos encontrados:"
    cat "$RESULT_DIR/08_files_named_flag.txt"
    echo ""
    echo "[+] Tentando ler conteúdo dos arquivos encontrados..."
    while IFS= read -r file; do
        echo "--- Conteúdo de: $file ---" >> "$RESULT_DIR/09_flag_files_content.txt"
        cat "$file" 2>/dev/null >> "$RESULT_DIR/09_flag_files_content.txt" || echo "[ERRO] Não foi possível ler: $file" >> "$RESULT_DIR/09_flag_files_content.txt"
        echo "" >> "$RESULT_DIR/09_flag_files_content.txt"
    done < "$RESULT_DIR/08_files_named_flag.txt"
    echo "[+] Conteúdo salvo em: $RESULT_DIR/09_flag_files_content.txt"
else
    echo "[!] Nenhum arquivo com 'flag' no nome encontrado"
fi

echo ""
echo "[2.2] Buscando padrão 'Solyd{' em arquivos..."
find / -type f -exec grep -l "Solyd{" {} \; 2>/dev/null > "$RESULT_DIR/10_solyd_pattern_files.txt"
if [ -s "$RESULT_DIR/10_solyd_pattern_files.txt" ]; then
    echo "[!] ARQUIVOS COM PADRÃO Solyd{ ENCONTRADOS:"
    cat "$RESULT_DIR/10_solyd_pattern_files.txt"
    echo ""
    echo "[+] Extraindo flags encontradas..."
    while IFS= read -r file; do
        echo "--- Flags em: $file ---" >> "$RESULT_DIR/11_flags_found.txt"
        grep -o "Solyd{[^}]*}" "$file" 2>/dev/null >> "$RESULT_DIR/11_flags_found.txt" || echo "[ERRO] Não foi possível ler: $file" >> "$RESULT_DIR/11_flags_found.txt"
        echo "" >> "$RESULT_DIR/11_flags_found.txt"
    done < "$RESULT_DIR/10_solyd_pattern_files.txt"
    cat "$RESULT_DIR/11_flags_found.txt"
else
    echo "[!] Nenhum arquivo com padrão Solyd{ encontrado"
fi

# ============================================
# PRIORIDADE MÉDIA 1: Diretório Home do Ubuntu
# ============================================
echo ""
echo "=========================================="
echo "[PRIORIDADE MÉDIA] Explorando /home/ubuntu..."
echo "=========================================="
echo ""

if [ -d /home/ubuntu ]; then
    echo "[3.1] Listando conteúdo de /home/ubuntu..."
    ls -la /home/ubuntu/ > "$RESULT_DIR/12_ubuntu_home.txt" 2>&1
    cat "$RESULT_DIR/12_ubuntu_home.txt"
    
    echo ""
    echo "[3.2] Buscando flags no diretório ubuntu..."
    find /home/ubuntu -name "*flag*" 2>/dev/null > "$RESULT_DIR/13_ubuntu_flags.txt"
    find /home/ubuntu -type f -exec grep -l "Solyd{" {} \; 2>/dev/null >> "$RESULT_DIR/13_ubuntu_flags.txt"
    
    if [ -s "$RESULT_DIR/13_ubuntu_flags.txt" ]; then
        echo "[+] Arquivos encontrados:"
        cat "$RESULT_DIR/13_ubuntu_flags.txt"
    else
        echo "[!] Nenhuma flag encontrada em /home/ubuntu"
    fi
    
    echo ""
    echo "[3.3] Verificando .bash_history do ubuntu..."
    if [ -f /home/ubuntu/.bash_history ]; then
        cat /home/ubuntu/.bash_history > "$RESULT_DIR/14_ubuntu_bash_history.txt" 2>&1
        echo "[+] Histórico salvo (últimas 20 linhas):"
        tail -20 "$RESULT_DIR/14_ubuntu_bash_history.txt"
    fi
    
    echo ""
    echo "[3.4] Buscando arquivos ocultos em /home/ubuntu..."
    find /home/ubuntu -name ".*" -type f 2>/dev/null > "$RESULT_DIR/15_ubuntu_hidden.txt"
    if [ -s "$RESULT_DIR/15_ubuntu_hidden.txt" ]; then
        cat "$RESULT_DIR/15_ubuntu_hidden.txt"
    fi
else
    echo "[!] Diretório /home/ubuntu não encontrado"
fi

# ============================================
# PRIORIDADE MÉDIA 2: Exploração Avançada do Below
# ============================================
echo ""
echo "=========================================="
echo "[PRIORIDADE MÉDIA] Exploração avançada do comando below..."
echo "=========================================="
echo ""

if command -v /usr/local/bin/below >/dev/null 2>&1; then
    echo "[4.1] Verificando ajuda do below..."
    sudo /usr/local/bin/below --help > "$RESULT_DIR/16_below_help.txt" 2>&1
    cat "$RESULT_DIR/16_below_help.txt"
    
    echo ""
    echo "[4.2] Tentando criar diretório necessário para snapshot..."
    sudo mkdir -p /var/log/below/store 2>/dev/null
    ls -la /var/log/below/ > "$RESULT_DIR/17_below_dir.txt" 2>&1
    
    echo ""
    echo "[4.3] Tentando outros subcomandos do below..."
    sudo /usr/local/bin/below list > "$RESULT_DIR/18_below_list.txt" 2>&1
    sudo /usr/local/bin/below record > "$RESULT_DIR/19_below_record.txt" 2>&1
    
    echo ""
    echo "[4.4] Buscando arquivos de configuração do below..."
    find /etc /usr -name "*below*" 2>/dev/null > "$RESULT_DIR/20_below_config_files.txt"
    if [ -s "$RESULT_DIR/20_below_config_files.txt" ]; then
        echo "[+] Arquivos encontrados:"
        cat "$RESULT_DIR/20_below_config_files.txt"
    fi
    
    echo ""
    echo "[4.5] Verificando logs do below..."
    ls -la /var/log/below/ > "$RESULT_DIR/21_below_logs.txt" 2>&1
    cat "$RESULT_DIR/21_below_logs.txt"
else
    echo "[!] Comando below não encontrado"
fi

# ============================================
# PRIORIDADE BAIXA: Outras Explorações
# ============================================
echo ""
echo "=========================================="
echo "[PRIORIDADE BAIXA] Outras explorações..."
echo "=========================================="
echo ""

echo "[5.1] Verificando diretório /root..."
ls -la /root/ > "$RESULT_DIR/22_root_dir.txt" 2>&1
if [ -s "$RESULT_DIR/22_root_dir.txt" ]; then
    echo "[+] Conteúdo de /root:"
    cat "$RESULT_DIR/22_root_dir.txt"
fi

echo ""
echo "[5.2] Buscando flags em /root..."
find /root -name "*flag*" -o -type f -exec grep -l "Solyd{" {} \; 2>/dev/null > "$RESULT_DIR/23_root_flags.txt"
if [ -s "$RESULT_DIR/23_root_flags.txt" ]; then
    echo "[!] ARQUIVOS ENCONTRADOS EM /root:"
    cat "$RESULT_DIR/23_root_flags.txt"
fi

echo ""
echo "[5.3] Verificando diretórios /opt, /srv, /usr/local..."
ls -la /opt/ > "$RESULT_DIR/24_opt_dir.txt" 2>&1
ls -la /srv/ > "$RESULT_DIR/25_srv_dir.txt" 2>&1
ls -la /usr/local/ > "$RESULT_DIR/26_usr_local_dir.txt" 2>&1

echo ""
echo "[5.4] Buscando flags em diretórios comuns..."
for dir in /opt /srv /usr/local /var/log; do
    find "$dir" -name "*flag*" 2>/dev/null >> "$RESULT_DIR/27_common_dirs_flags.txt"
    find "$dir" -type f -exec grep -l "Solyd{" {} \; 2>/dev/null >> "$RESULT_DIR/27_common_dirs_flags.txt"
done
if [ -s "$RESULT_DIR/27_common_dirs_flags.txt" ]; then
    echo "[+] Arquivos encontrados:"
    cat "$RESULT_DIR/27_common_dirs_flags.txt"
fi

echo ""
echo "[5.5] Verificando logs do Apache..."
if [ -f /var/log/apache2/access.log ]; then
    tail -50 /var/log/apache2/access.log > "$RESULT_DIR/28_apache_access.log" 2>&1
    echo "[+] Últimas 50 linhas do access.log salvas"
fi
if [ -f /var/log/apache2/error.log ]; then
    tail -50 /var/log/apache2/error.log > "$RESULT_DIR/29_apache_error.log" 2>&1
    echo "[+] Últimas 50 linhas do error.log salvas"
    echo "[+] Verificando se há flags nos logs..."
    grep -i "solyd\|flag" /var/log/apache2/error.log 2>/dev/null | tail -20 || echo "Nenhuma flag encontrada nos logs"
fi

echo ""
echo "[5.6] Verificando processos rodando como root..."
ps aux | grep root > "$RESULT_DIR/30_root_processes.txt" 2>&1
echo "[+] Processos salvos"

echo ""
echo "[5.7] Verificando conexões de rede..."
netstat -tulpn 2>/dev/null > "$RESULT_DIR/31_network_connections.txt" || ss -tulpn > "$RESULT_DIR/31_network_connections.txt" 2>&1
echo "[+] Conexões salvas"

echo ""
echo "[5.8] Verificando variáveis de ambiente (se possível como adalberto)..."
env > "$RESULT_DIR/32_environment.txt" 2>&1
echo "[+] Variáveis de ambiente salvas"

# ============================================
# RESUMO FINAL
# ============================================
echo ""
echo "=========================================="
echo "  RESUMO DA BUSCA"
echo "=========================================="
echo ""
echo "[+] Busca concluída em $(date)"
echo "[+] Todos os resultados salvos em: $RESULT_DIR"
echo ""
echo "[+] Arquivos mais importantes para verificar:"
echo "    - $RESULT_DIR/11_flags_found.txt (Flags encontradas)"
echo "    - $RESULT_DIR/02_settings_json.txt (settings.json)"
echo "    - $RESULT_DIR/03_test_php.txt (test.php)"
echo "    - $RESULT_DIR/04_test_txt.txt (test.txt)"
echo "    - $RESULT_DIR/09_flag_files_content.txt (Conteúdo de arquivos flag)"
echo ""
echo "[+] Listando todos os arquivos de resultado:"
ls -lh "$RESULT_DIR/"
echo ""
echo "=========================================="
echo "  FIM DA BUSCA"
echo "=========================================="
