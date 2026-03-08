# Parte 1 — O que explorar agora (sem ser o below)

Você está com acesso ao servidor da **primeira parte** de novo. Abaixo está o que **ainda não temos** e que pode dar **indícios para a rede interna** (parte 2). Tudo pode ser feito por shell (www-data ou adalberto).

---

## 1. Rede e hosts (prioridade alta)

Objetivo: descobrir IPs, hostnames e serviços internos.  
*(No container pode não existir `ip` nem `arp` — use as alternativas abaixo.)*

```bash
# Hosts estáticos (pode ter projetos-blogo.sy ou outros internos)
cat /etc/hosts

# Interfaces (sem ip addr)
cat /proc/net/dev
ls /sys/class/net/

# IPs do host (se existir)
hostname -I 2>/dev/null

# Rotas (sem ip route) — colunas: Iface Dest Gateway...
cat /proc/net/route

# DNS e domínio de busca (ex.: ec2.internal)
cat /etc/resolv.conf

# Conexões TCP/UDP ativas (sem ss/netstat)
cat /proc/net/tcp
cat /proc/net/udp

# Tabela ARP (sem arp) — colunas: IP, HW type, Flags, MAC, Mask, Device
cat /proc/net/arp
```

**Anotar:** qualquer IP 10.x na coluna “IP” do ARP ou em /etc/hosts; hostname que não seja só “localhost”; nomes tipo *projetos*, *blogo*, *internal*.

---

## 2. Apache — configuração e proxies

Objetivo: ver se há ProxyPass, Redirect ou ServerName para servidores internos.

```bash
# Vhosts e aliases
cat /etc/apache2/sites-enabled/*
ls -la /etc/apache2/sites-enabled/

# Inclusões (outros vhosts ou configs)
grep -r "ProxyPass\|Redirect\|ServerName\|ServerAlias" /etc/apache2/ 2>/dev/null

# Config geral
cat /etc/apache2/apache2.conf 2>/dev/null | head -80
```

**Anotar:** qualquer URL interna, nome de host (ex.: projects-blogo.sy) ou IP em redirect/proxy.

---

## 3. Arquivos da aplicação que ainda não lemos

Objetivo: URLs internas, credenciais, paths da parte 2.

```bash
# test.php (2588 bytes) — pode ter lógica ou links internos
cat /var/www/blogo/test.php

# Código de noticias.php (além do que já vimos no browser)
head -200 /var/www/blogo/noticias.php

# index.html — links ou comentários
cat /var/www/blogo/index.html | head -100

# Diretório files/ (upload? listagem?)
ls -la /var/www/blogo/files/
```

**Anotar:** qualquer host, path “/projetos”, “projects-blogo”, IP ou menção a “rede interna” / “homologação”.

---

## 4. Logs do Apache

Objetivo: IPs de acesso, Host headers (ex.: projects-blogo.sy), referrers internos.

```bash
# Últimas linhas (acessos e erros)
tail -100 /var/log/apache2/access.log
tail -50 /var/log/apache2/error.log

# Buscar Host interno ou IP 10.x
grep -E "projects-blogo|10\.0\.|internal" /var/log/apache2/access.log 2>/dev/null
```

**Anotar:** Host header diferente (ex.: projects-blogo.sy), IPs 10.x ou de rede interna.

---

## 5. Cron e systemd (tarefas que podem falar com a rede interna)

```bash
# Cron
ls -la /etc/cron.d/ /etc/cron.daily/ /etc/cron.hourly/ 2>/dev/null
cat /etc/cron.d/* 2>/dev/null
for u in root adalberto www-data; do crontab -l -u $u 2>/dev/null; done

# Serviços (unit files que rodam scripts ou conectam em algo)
systemctl list-units --type=service 2>/dev/null
ls /etc/systemd/system/*.service 2>/dev/null
grep -l "curl\|wget\|mysql\|ssh\|below" /etc/systemd/system/*.service 2>/dev/null
```

**Anotar:** qualquer script que use URL interna, IP 10.x ou outro host.

---

## 6. Home dos usuários (histórico e chaves SSH)

Objetivo: comandos que acessaram hosts internos e chaves para pivot.

```bash
# adalberto
cat /home/adalberto/.bash_history
ls -la /home/adalberto/.ssh/ 2>/dev/null
cat /home/adalberto/.ssh/config 2>/dev/null
cat /home/adalberto/.ssh/known_hosts 2>/dev/null

# ubuntu (quase não exploramos)
ls -la /home/ubuntu/
cat /home/ubuntu/.bash_history 2>/dev/null
ls -la /home/ubuntu/.ssh/ 2>/dev/null
```

**Anotar:** IPs, hostnames, comandos `ssh`, `curl`, `below -s host`, etc.

---

## 7. MySQL — variáveis e metadados

Objetivo: hostname do servidor, outros DBs ou referências.

```bash
# Na shell do servidor
mysql --protocol=TCP -h 127.0.0.1 -u blogodb -p'WPcmqw16ZmzO!5paSC4' -e "
SHOW VARIABLES LIKE '%hostname%';
SHOW VARIABLES LIKE '%datadir%';
SELECT * FROM information_schema.SCHEMATA;
SELECT table_schema, table_name FROM information_schema.TABLES LIMIT 50;
"
```

**Anotar:** hostname, nomes de schemas/tabelas que não sejam só information_schema/performance_schema.

---

## 8. Processos e variáveis de ambiente

Objetivo: ver se algum processo usa URL ou host interno.

```bash
# Processos com linha de comando completa
ps auxeww 2>/dev/null | head -80

# Variáveis de ambiente do Apache (podem ter DB host ou URL)
cat /proc/$(pgrep -f apache2 | head -1)/environ 2>/dev/null | tr '\0' '\n'
```

**Anotar:** qualquer hostname ou URL em comando ou env.

---

## 9. /var/log/below e outros logs

```bash
# Below: pode ter hostnames em logs
ls -la /var/log/below/
cat /var/log/below/* 2>/dev/null

# Outros logs no sistema
ls -la /var/log/
grep -r "10\.0\.\|internal\|projetos\|blogo" /var/log/*.log 2>/dev/null | head -20
```

**Anotar:** hostnames ou IPs internos em mensagens de log.

---

## 10. Busca por configurações com host/URL

```bash
# Configs que mencionam host, url, proxy, internal
grep -ri "host\|url\|proxy\|internal\|10\.0\.\|blogo\|projeto" /etc/apache2/ /var/www/blogo/*.php /var/www/blogo/config/ 2>/dev/null
```

---

## Resumo rápido (ordem sugerida)

| # | O quê | Comando principal |
|---|--------|-------------------|
| 1 | Rede e hosts | `cat /etc/hosts` + `cat /proc/net/arp` + `cat /proc/net/tcp` |
| 2 | Apache (proxy/redirect) | `cat /etc/apache2/sites-enabled/*` |
| 3 | test.php e files/ | `cat /var/www/blogo/test.php` + `ls /var/www/blogo/files/` |
| 4 | Logs Apache | `tail /var/log/apache2/access.log` + grep por Host / 10.0. |
| 5 | Cron/systemd | `cat /etc/cron.d/*` + listar services |
| 6 | .bash_history e .ssh (adalberto, ubuntu) | `cat /home/adalberto/.bash_history` etc. |
| 7 | MySQL (hostname, schemas) | `SHOW VARIABLES` + `information_schema` |
| 8 | Processos e env do Apache | `ps auxeww` + `cat /proc/.../environ` |
| 9 | /var/log/below e outros logs | `ls /var/log/below` + grep em /var/log |
| 10 | Grep em configs | grep host/url/proxy em /etc e /var/www |

Depois de rodar, vale jogar no **PARTE1_INDICIOS_REDE_INTERNA.md** qualquer IP, hostname, URL ou path novo que aparecer — e testar na **parte 2** (44.197.245.141 / projects-blogo.sy) com essas pistas.
