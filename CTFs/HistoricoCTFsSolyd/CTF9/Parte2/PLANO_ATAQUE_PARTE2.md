# Plano de Ataque — CTF9 Parte 2

## 1. Contexto e cenário

### Dica da plataforma
- O pentest no **site de notícias da Rede Blogo (Parte 1)** terminou.
- Há **indícios de atividade suspeita na rede interna** e **instabilidades em servidores/serviços**.
- **LightBringers** provavelmente **não pararam no acesso inicial**: usaram o servidor comprometido como **ponte para a infraestrutura interna**.

### O que temos da Parte 1 (sem acesso ao servidor agora)
- **Credenciais:** `adalberto` / `blogodb` → senha: `WPcmqw16ZmzO!5paSC4`
- **Domínios:** `blogo.sy`, `ti@blogo.sy`, **`projects-blogo.sy`** (citado no material da Parte 2)
- **Rede interna (quando Part 1 estiver ativa):** 10.0.x.x, gateway 10.0.0.1, hostname tipo `ip-10-0-XX-XXX`
- **Pista histórica:** header **`x-host: projects-blogo.sy`** ou **`Host: projects-blogo.sy`** no alvo da Parte 2 (nginx, “Ambiente de Testes”)

### Alvo atual
- **IP:** **23.21.16.51** (o IP da Parte 2 muda a cada hora ao encerrar/subir ambiente; o cenário é o mesmo)
- **Observação:** Não é possível acessar a Parte 1 ao mesmo tempo; se precisar de algo do servidor Blogo, será preciso trocar o ambiente. Por ora, ataque **direto** ao IP da Parte 2.

---

## 2. Objetivos

1. **Reconhecimento** do alvo 23.21.16.51 (portas, serviços, web).
2. **Acesso ao serviço web** usando o host correto (`projects-blogo.sy`).
3. **Exploração** da aplicação (diretórios, parâmetros, possíveis vulnerabilidades).
4. **Reutilização de credenciais** da Parte 1 (blogodb/adalberto e variações).
5. **Busca de flags** e evidências de “rede interna” / próximos passos do CTF.

---

## 3. Fase 1 — Reconhecimento (do seu Kali)

### 3.1 Nmap (portas e serviços)
```bash
# Scan rápido das portas mais comuns
nmap -sS -sV -sC -Pn -p 1-1000,3306,8080,8443 23.21.16.51 -oN Parte2/nmap_23.21.16.51_1-1000.txt

# Scan completo (se o tempo permitir)
nmap -sS -sV -sC -Pn -p- 23.21.16.51 -oN Parte2/nmap_23.21.16.51_full.txt
```
- Anotar: **porta 80 (HTTP)** e qualquer outra aberta (SSH 22, MySQL 3306, etc.).

### 3.2 Resolução DNS / hostname
- Nos scans antigos o host aparecia como **projects-blogo.sy** (ex.: 3.236.197.144).
- Se quiser testar: `dig projects-blogo.sy` ou `host 23.21.16.51` (pode não resolver para o IP novo).
- **Não depender de DNS:** usar sempre **Host header** na web.

---

## 4. Fase 2 — Serviço web (porta 80)

### 4.1 Acesso com Host correto
O site pode responder só com o host certo (virtual host):

```bash
# Com curl
curl -v -H "Host: projects-blogo.sy" http://23.21.16.51/

# Alternativa (alguns cenários usam x-host)
curl -v -H "x-host: projects-blogo.sy" http://23.21.16.51/
```

- Se a resposta for diferente (ex.: “Ambiente de Testes” ou conteúdo específico), anotar e seguir nesse vhost.

### 4.2 Navegação manual
- Abrir no browser: `http://23.21.16.51/` e configurar **Host** para `projects-blogo.sy` (extensão “ModHeader” ou similar), ou usar o curl acima e inspecionar links/forms.
- Procurar: login, painéis, mensagens de erro, comentários no HTML, flags em comentários (estilo Parte 1).

### 4.3 Fuzzing de diretórios e arquivos
```bash
# Exemplo com ffuf (ajustar wordlist e tamanhos)
ffuf -w /usr/share/wordlists/dirb/common.txt -u http://23.21.16.51/FUZZ -H "Host: projects-blogo.sy" -mc 200,301,302,403 -fc 404 -o Parte2/ffuf_dirs.json

# Extensões comuns em PHP/sites
ffuf -w /usr/share/wordlists/dirb/common.txt -u http://23.21.16.51/FUZZ -e .php,.html,.txt,.bak -H "Host: projects-blogo.sy" -mc 200,301,302,403 -fc 404
```
- Anotar paths interessantes: `/admin`, `/login`, `/config`, `/backup`, `.git`, etc.

### 4.4 Fuzzing de subdomínios / VirtualHost (se aplicável)
```bash
# Exemplo: trocar Host por outro possível vhost
ffuf -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -u http://23.21.16.51/ -H "Host: FUZZ.projects-blogo.sy" -mc 200,301,302 -fs <tamanho_da_resposta_padrão>
```

---

## 5. Fase 3 — Credenciais e exploração

### 5.1 Reutilização de credenciais da Parte 1
- **Usuário/senha:** `blogodb` ou `adalberto` com `WPcmqw16ZmzO!5paSC4`.
- Testar em:
  - Formulários de **login** (web, API).
  - **SSH:** `ssh adalberto@23.21.16.51`, `ssh blogodb@23.21.16.51` (se porta 22 aberta).
  - **MySQL:** `mysql -h 23.21.16.51 -u blogodb -p'WPcmqw16ZmzO!5paSC4'` (se 3306 aberta).
- Variações de usuário: `admin`, `root`, `ti`, `joao.cleber` (nome citado na dica), etc.

### 5.2 Possíveis vetores (conforme descobertas)
- **LFI / path traversal** (estilo `noticias.php?text=...` da Parte 1).
- **Injeção em parâmetros** (SQLi, command injection) em forms ou query strings.
- **Arquivos sensíveis:** `/config.php`, `.env`, `backup.sql`, chaves SSH em paths comuns.
- **Headers e cookies** deixados pela aplicação (sessão, tokens).

---

## 6. Fase 4 — Rede interna e pivô (quando Part 1 estiver acessível)

Quando você **tiver novamente o servidor da Parte 1** (trocar ambiente):

1. **Pivô a partir do Blogo (root/0xdtc):**
   - Túnel SSH: `ssh -D 1080 -N 0xdtc@<IP_PUBLICO_PARTE1>` → proxy SOCKS5 em 127.0.0.1:1080.
   - Port forwarding para host interno: `ssh -L 2222:10.0.X.Y:22 0xdtc@<IP_PUBLICO_PARTE1>`.

2. **Varredura da rede 10.0.x.x** a partir do shell no Blogo:
   - `ip addr`, `ip route`, `ip neigh` (ou `arp -a`).
   - Ping sweep ou `nmap -sn 10.0.0.0/24` (se nmap/nc disponíveis no pivô).

3. **Artefatos no Blogo** (conforme PARTE1_ROOT_PARA_PARTE2.md):
   - `cat /root/.ssh/authorized_keys`, `/home/*/.ssh/`
   - `cat /root/.bash_history`, configs em `/var/www/blogo/`
   - Metadata AWS (169.254.169.254) se for EC2, para credenciais S3/EC2.

Por ora, como **não temos Part 1**, focar em tudo que for possível **diretamente** em 23.21.16.51.

---

## 7. Checklist de execução

| # | Ação | Feito? |
|---|------|--------|
| 1 | Nmap em 23.21.16.51 (portas 1-1000 e principais) | [ ] |
| 2 | Acessar http://23.21.16.51 com `Host: projects-blogo.sy` | [ ] |
| 3 | Anotar título, links, formulários e possíveis flags no HTML | [ ] |
| 4 | Fuzzing de diretórios (ffuf/gobuster) com Host correto | [ ] |
| 5 | Testar login/SSH/MySQL com blogodb e adalberto + senha Parte 1 | [ ] |
| 6 | Procurar LFI, SQLi ou outros vetores conforme descobertas | [ ] |
| 7 | Se encontrar acesso (shell/SSH): enumerar e procurar flags | [ ] |
| 8 | Quando Part 1 estiver ativa: pivô e varredura 10.0.x.x (opcional) | [ ] |

---

## 8. Resumo de artefatos da Parte 1 (referência rápida)

| Item | Valor |
|------|--------|
| Senha compartilhada (adalberto / blogodb) | `WPcmqw16ZmzO!5paSC4` |
| Domínio / vhost Parte 2 | `projects-blogo.sy` |
| Contato TI | ti@blogo.sy |
| Rede interna (Parte 1) | 10.0.x.x, gateway 10.0.0.1 |
| Usuário root (Parte 1) | 0xdtc (senha vazia) |

---

*Documento gerado para guiar o ataque à Parte 2 com base na dica da plataforma, na coleta da Parte 1 e nos scans existentes na pasta Parte2. Atualizar este plano conforme novos IPs ou descobertas.*
