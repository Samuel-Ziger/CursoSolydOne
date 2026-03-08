# Parte 1 → Indícios para a Rede Interna (Parte 2)

Tudo da **primeira parte** do CTF9 que pode **direcionar ou servir de pista** para a **rede interna** na segunda parte.

---

## 1. Dica da plataforma (Parte 2)

> "O pentest no site de notícias da Rede Blogo terminou, mas a sensação de encerramento nunca veiu.  
> Enquanto revisava os artefatos coletados na **primeira etapa**, você percebeu algo inquietante: **pequenos indícios de atividade suspeita na rede interna**. Além disso **João Cleber, chefe da TI da Rede Blogo**, disse que **alguns servidores e serviços da rede interna** passaram por **diversas instabilidades**. Não havia logs que contassem a história inteira, mas havia **ruído demais para ser coincidência**.  
> Você suspeita fortemente que o **LightBringers** não parou no acesso inicial. Eles podem ter **extraído informações do servidor comprometido** anteriormente e **usado isso como ponte para a infraestrutura interna**."

**Indícios explícitos:**
- **Rede interna** existe e foi alvo de atividade suspeita.
- **João Cleber** = chefe da TI da Blogo (nome para possíveis paths/usuários/senhas).
- **LightBringers** = grupo atacante; pode aparecer em assinaturas, paths ou textos.
- **Servidor da parte 1 = ponte**: dados extraídos dele (credenciais, hostnames, serviços) podem ser usados na parte 2.

---

## 2. IPs e hosts (Parte 1)

| Tipo | Valor | Uso na rede interna |
|------|--------|----------------------|
| **Site de notícias (Parte 1)** | 98.86.169.119 | ec2-98-86-169-119.compute-1.amazonaws.com — servidor já comprometido; não acessível agora. |
| **MySQL (Parte 1)** | 13.220.129.145 | ec2-13-220-129-145.compute-1.amazonaws.com — banco acessível da parte 1; IP pode mudar pela plataforma. |
| **Parte 2 (atual)** | 44.197.245.141 | Alvo da rede interna; no seu hosts como **projects-blogo.sy**. |
| **Script reverse_shell.sh** | 44.197.173.254 | DEFAULT_TARGET_IP no script — pode ser outro host da mesma infra (staging/projetos). |

**Observação:** Os IPs da parte 1 “mudam conforme o tempo acaba” na plataforma, mas a **estrutura** (dois IPs: web + MySQL) e o **padrão AWS (ec2-*.compute-1.amazonaws.com)** indicam ambiente cloud; a parte 2 pode seguir padrões parecidos.

---

## 3. Rede interna vista de dentro do servidor (Parte 1)

### 3.1 Hostnames (padrão AWS 10.0.x.x)

Vários hostnames aparecem nos artefatos; todos no padrão **ip-10-0-X-Y** (subnet **10.0.0.0/16** típica de VPC AWS):

| Hostname | Onde aparece |
|----------|----------------|
| ip-10-0-3-227 | Servidor.txt, RELATORIO (uname, below, sudo) |
| ip-10-0-99-169 | flags.txt, credencial.txt |
| ip-10-0-117-3 | Mysql.txt (shell onde roda mysql local) |
| ip-10-0-163-175 | linpeasAdalberto.txt (hostname, container ID, sudo) |

**Indício:** A rede interna usa **10.0.x.x**. Na parte 2, se você tiver acesso a algum host interno, procurar por outros **ip-10-0-*** ou serviços em **10.0.0.0/8** pode fazer sentido.

### 3.2 Interfaces e rede (linpeas / Servidor)

- **Interfaces:** `ens5` (rede AWS), `docker0` (Docker).
- **DNS (resolv.conf):** `127.0.0.53`, **search ec2.internal** → domínio interno AWS.
- **Portas em listen (container):** 53 (DNS), 3306 (MySQL), 33060 (MySQL X Protocol), tudo em 127.0.0.x ou 0.0.0.0.
- **/etc/hosts (dentro do container):** só localhost e entradas IPv6; nenhum host extra da Blogo listado.

**Indício:** Ambiente **AWS (ec2.internal)** com containers; “rede interna” da parte 2 pode ser outra VPC ou outro segmento (ex.: 44.197.x.x) acessível a partir de um único IP liberado (44.197.245.141).

### 3.3 Ferramenta **below** e acesso remoto à rede interna

No servidor comprometido, o usuário **adalberto** pode rodar:

```bash
sudo /usr/local/bin/below snapshot -s, --host <HOST>   # hostname para snapshot REMOTO
      --port <PORT>                                    # porta para conexão remota
sudo /usr/local/bin/below dump -s, --host <HOST>      # idem para dump remoto
      --port <PORT>
```

**Indício forte:** O binário **below** foi configurado para **conectar a outros hosts** (rede interna). Ou seja, na infra da Blogo pode existir **outros servidores com o serviço “below”** acessíveis a partir do host comprometido. Na parte 2, mesmo sem shell na parte 1, isso sugere:
- existência de **mais hosts/serviços internos**;
- possíveis **hostnames** ou **portas** ligados a “below” ou monitoramento (ex.: projetos, TI).

---

## 4. Credenciais (reutilização entre sistemas)

Todas devem ser **testadas na parte 2** (login web, SSH, painéis, APIs, etc.):

| Contexto | Usuário | Senha | Onde apareceu |
|----------|---------|--------|----------------|
| **MySQL** | blogodb | WPcmqw16ZmzO!5paSC4 | config.php (back.zip), Mysql.txt |
| **Sistema Linux** | adalberto | WPcmqw16ZmzO!5paSC4 | Mesma senha do DB; su adalberto na shell |
| **Sistema** | www-data | (sem senha útil) | Acesso via LFI/shell |

**Indício:** Reutilização de senha (DB = usuário adalberto). Na rede interna é comum **mesma senha em mais máquinas** (TI, João Cleber, serviços internos). Testar **adalberto** e **blogodb** (e variações como **joaocleber**, **ti**, **admin**) com **WPcmqw16ZmzO!5paSC4** em qualquer login da parte 2.

---

## 5. Configuração do aplicativo (config.php)

```php
'db' => [
    'driver'  => 'mysql',
    'host'    => '127.0.0.1',   // no servidor web era local
    'port'    => 3306,
    'name'    => 'blogodb',
    'user'    => 'blogodb',
    'pass'    => 'WPcmqw16ZmzO!5paSC4',
]
```

**Indício:** Nomes **blogodb**, **blogo**; porta **3306**. Na parte 2, se aparecer qualquer serviço MySQL (ou painel que use esse DB), essas credenciais e o nome **blogodb** são candidatos. Também vale procurar por **backups ou configs** que apontem para outros hosts internos (ex.: outro `host` diferente de 127.0.0.1).

---

## 6. Estrutura de arquivos e paths (Parte 1)

- **Web:** `/var/www/blogo/` — noticias.php, shell.php, config/, files/, back.zip.
- **Paths sensíveis:** `/var/www/blogo/config/config.php`, **back.zip** (backup com config).
- **Usuários no /home:** adalberto, ubuntu.

**Indício:** Na rede interna (parte 2) podem existir:
- paths como **/projetos**, **/blogo**, **/noticias**, **/config**, **/files**;
- nomes como **blogo**, **noticias**, **projetos** (a página da parte 2 fala em “Ambiente de Testes de **Projetos**” e “builds/artefatos”).

---

## 7. Nomes e termos do cenário (para paths, usuários, mensagens)

Extraídos da dica e do relatório; úteis para **paths**, **Host headers**, **usuários** e **textos** na parte 2:

| Termo | Origem |
|-------|--------|
| **João Cleber** | Chefe da TI (dica parte 2) |
| **LightBringers** | Grupo atacante |
| **Rede Blogo** | Empresa |
| **setor de TI** | Texto da página “Ambiente de Testes” (parte 2) |
| **projetos**, **builds**, **artefatos**, **homologação**, **validação** | Mesma página |
| **projects-blogo.sy** | Host que você colocou no /etc/hosts para 44.197.245.141 |

Sugestão: testar em URLs, vhosts ou logins combinações como **joao-cleber**, **joaocleber**, **lightbringers**, **rede-interna**, **ti**, **projetos**, **artefatos**, **homolog**, **validação**.

---

## 8. Serviços e portas (Parte 1)

| Porta | Serviço | Observação |
|-------|---------|------------|
| 80 | HTTP (Apache no container) | Site de notícias; na parte 2 há nginx em 44.197.245.141:80. |
| 3306 | MySQL | Acessível localmente no servidor; na parte 2 pode haver MySQL em outro IP/host. |
| 33060 | MySQL X Protocol | Listen no container (linpeas). |
| 25 | SMTP | Filtrada no nmap; possível vetor interno (e-mail, usuários). |

**Indício:** Se na parte 2 surgir outro host acessível (por exemplo após encontrar uma flag), vale **repetir enumeração de portas** (80, 443, 22, 25, 3306, 8080, etc.) como na parte 1.

---

## 9. Resumo: o que usar na Parte 2

1. **Credenciais:** adalberto / blogodb com **WPcmqw16ZmzO!5paSC4** em qualquer login (web, SSH, painel, API).
2. **Host da parte 2:** **44.197.245.141** com **Host: projects-blogo.sy** (já no seu /etc/hosts).
3. **Nomes para paths/vhosts:** projetos, builds, artefatos, ti, joao-cleber, lightbringers, rede-interna, noticias, blogo, config.
4. **Rede interna:** padrão 10.0.x.x (hostnames ip-10-0-*); “below” indica outros hosts/serviços acessíveis a partir do servidor comprometido; domínio **ec2.internal**.
5. **IP do reverse_shell.sh:** 44.197.173.254 — anotar como possível outro host da mesma infra.
6. **Padrão de flags:** formato **Solyd{...}**; na parte 2 as 4 flags devem ser nesse formato e “reais” (não conceituais).

---

*Documento gerado a partir de: RELATORIO_CTF9.md, Servidor.txt, flags.txt, credencial.txt, Mysql.txt, linpeasAdalberto.txt, nmap, reverse_shell.sh e dica da plataforma (Parte 2).*
