# CTF9 Parte 3 – Resumo do ataque e automação

**Alvo:** 98.92.111.173 (lb-test / ec2-98-92-111-173.compute-1.amazonaws.com)  
**Objetivo:** Encontrar as 4 flags (todas no mesmo IP).  
**Restrição:** Não atacar a porta 22 (SSH).

---

## Situação atual (dos arquivos do projeto)

- **nmap já feito:** -A, -p-, banners, smtp-commands, UDP top-100, ssh-auth-methods.
- **Portas conhecidas:**
  - **22/tcp** – aberta, SSH (OpenSSH 9.6). **Não atacar.**
  - **25/tcp** – filtrada (SMTP). No `nc` aceitou conexão; ao enviar `EHLO test` houve resposta.
  - **137, 138/tcp** – filtradas (NetBIOS).
  - **58000/tcp** – filtrada. No `nc` ao enviar `helo` o serviço devolveu `helo` (eco).
  - **137–139/udp** – open|filtered (NetBIOS); **5060/udp** – open|filtered (SIP).
- **Dica da plataforma:** Alvo é **lb-test**; mensagem do F3uH3Ad.

---

## Onde procurar as 4 flags

1. **Porta 25 (SMTP)** – Comandos SMTP (EHLO, VRFY, EXPN, HELP, etc.) podem revelar usuários ou mensagens com flags. Rodar `smtp_enum.py` ou interagir com `nc 98.92.111.173 25`.
2. **Porta 58000** – Serviço que ecoa. Testar palavras como `flag`, `help`, `lb-test`; pode devolver flags. Rodar `porta_58000.py` ou `exploit_all.py`.
3. **NetBIOS/SMB (137, 138, 139)** – Enumeração com nbtscan/enum4linux; se houver shares ou usuários, flags em arquivos. Daqui as portas estavam filtradas/fechadas.
4. **Quarta flag** – Pode estar em outro serviço na mesma máquina (ex.: outro daemon em porta alta), em e-mail recebido via SMTP ou em share SMB; ou após obter acesso (ex.: SSH com credenciais encontradas em 25/58000/SMB).

---

## Resultados da automação (desta sessão)

- **SMTP 25:** timeout ao conectar daqui (porta filtrada/rede diferente).
- **58000:** timeout (idem).
- **137, 138:** timeout.
- **139:** connection refused → nmap mostra **closed**. Sem SMB ativo daqui.
- **nbtscan:** sem nomes NBT.
- **enum4linux:** sem workgroup; “No reply” no nbtstat.

Testes via MCP HexStrike (servidor remoto): também **timeout** em 25 e 58000.

Conclusão: da rede de teste e do servidor HexStrike só a **22** está acessível; 25 e 58000 podem estar acessíveis apenas de outra rede (ex.: VPN da plataforma do CTF). Os scripts abaixo servem para quando 25 e 58000 estiverem acessíveis.

---

## Scripts na pasta `automação`

| Script | Uso |
|--------|-----|
| `smtp_enum.py` | Enumera SMTP (EHLO, HELP, VRFY, EXPN, etc.). Salva em `smtp_enum_result.txt`. |
| `porta_58000.py` | Envia várias strings na 58000 (flag, help, lb-test…). Salva em `porta_58000_result.txt`. |
| `exploit_all.py` | Faz SMTP + 58000 + 137–139 em sequência. Salva em `exploit_all_result.txt`. |

**Como rodar (na pasta `automação`):**

```bash
cd "/home/kali/Desktop/CursoSolydOne/CTFs/HistoricoCTFsSolyd/CTF9/parte3/automação"
python3 smtp_enum.py
python3 porta_58000.py
python3 exploit_all.py
```

Se 25 ou 58000 estiverem acessíveis, ajuste timeouts no início dos scripts (ex.: `TIMEOUT = 15` ou mais).

---

## Arquivos de resultado

- `nbtscan_result.txt` – saída do nbtscan.
- `enum4linux_result.txt` – saída do enum4linux.
- `smtp_enum_result.txt` – saída do `smtp_enum.py` (se tiver conexão).
- `porta_58000_result.txt` – saída do `porta_58000.py` (se tiver conexão).
- `exploit_all_result.txt` – saída do `exploit_all.py`.
- `nmap_139.txt` – nmap apenas na porta 139.
- `nmap_web_extra.txt` – nmap em portas web/mail extras.

---

## Próximos passos sugeridos

1. Rodar os scripts a partir de uma rede onde 25 e 58000 respondam (ex.: VPN da plataforma).
2. Revisar todas as saídas em busca de strings no formato de flag (ex.: `Solyd`, `flag{`, etc.).
3. Se aparecer usuário/senha em SMTP ou em 58000, testar SSH (lb-test@98.92.111.173) **apenas com credenciais encontradas**, sem brute force na 22.
4. Repetir enum4linux/nbtscan quando 137–139 estiverem abertas/filtradas de forma a obter resposta.
