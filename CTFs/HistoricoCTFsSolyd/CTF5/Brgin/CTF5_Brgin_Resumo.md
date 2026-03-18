# CTF5 Brgin – Alvo: http://3.239.78.40/

## Resumo do recon (Hexstrike + WPScan)

- **Servidor:** Apache/2.4.52 (Ubuntu)  
- **CMS:** WordPress (versão não detectada)  
- **Tema:** Twenty Twenty-Three 1.0 (desatualizado, listing no diretório do tema habilitado)

---

## URLs prioritárias para procurar flags

| URL | Motivo |
|-----|--------|
| http://3.239.78.40/robots.txt | Pode revelar paths ocultos (Disallow) onde há flags |
| http://3.239.78.40/wp-content/uploads/ | **Directory listing habilitado** – listar e baixar arquivos |
| http://3.239.78.40/wp-content/themes/twentytwentythree/ | **Listing habilitado** – ver arquivos do tema (readme.txt, etc.) |
| http://3.239.78.40/readme.html | Info do WordPress |
| http://3.239.78.40/xmlrpc.php | XML-RPC ativo (enum usuários, brute, pingback) |

**Checar manualmente no navegador (o alvo deu timeout em ferramentas remotas):**

1. `robots.txt` – anotar todos os paths em `Disallow:` e acessar cada um.  
2. `wp-content/uploads/` – listar pastas por ano/mês (ex.: `/2024/01/`) e abrir arquivos suspeitos (.txt, .html, imagens com metadados).  
3. Dentro do tema: `readme.txt`, `style.css`, qualquer `.php` ou `.txt` extra.

---

## Vetores úteis (todas as flags existem)

- **Arquivos esquecidos:** backup.zip, flag.txt, secret.txt, .env, wp-config.bak, debug.log em `wp-content/`.  
- **Uploads:** arquivos enviados por usuários em `wp-content/uploads/` (nomes óbvios ou datas).  
- **robots.txt:** paths tipo `/secret/`, `/flag/`, `/backup/`, `/admin/`.  
- **Usuários WordPress:** XML-RPC permite enumerar usuários; depois testar senhas fracas (hydra/wpscan).  
- **Plugins vulneráveis:** WPScan não terminou a enumeração de plugins; rodar de novo com `--enumerate vp,vt` quando o alvo responder.  
- **LFI / leitura de arquivo:** se aparecer parâmetro em GET (ex. `?file=`) em páginas ou tema, testar path traversal.

---

## Comandos úteis (rodar na sua máquina)

```bash
# robots.txt e uploads (timeout curto)
curl -m 15 http://3.239.78.40/robots.txt
curl -m 15 http://3.239.78.40/wp-content/uploads/

# Discovery com poucos threads (se o alvo responder)
gobuster dir -u http://3.239.78.40/ -w /usr/share/wordlists/dirb/common.txt -t 5 -q
ffuf -u http://3.239.78.40/FUZZ -w /usr/share/wordlists/dirb/common.txt -mc 200,301,302,403 -t 5

# Fuzz de arquivos comuns de flag
ffuf -u http://3.239.78.40/wp-content/uploads/FUZZ -w wordlist_flag.txt -mc 200,301,403 -t 5
```

**wordlist_flag.txt** (criar e usar no ffuf/gobuster):

```
flag
flag.txt
secret
secret.txt
backup
backup.zip
key
key.txt
.env
wp-config.bak
readme
```

---

## Status das ferramentas (esta sessão)

- **WPScan:** rodou (timeout 5 min), enumerou tema e achados principais.  
- **Dirsearch:** falhou (erro no script do Hexstrike).  
- **Nuclei:** alvo marcado unresponsive (timeout).  
- **Nikto:** 0 hosts testados.  
- **Gobuster / fetch remoto:** timeout no alvo.

**Recomendação:** acessar as URLs prioritárias no browser ou com `curl` na sua rede; quando o alvo estabilizar, rodar de novo gobuster/ffuf/feroxbuster com poucos threads.
