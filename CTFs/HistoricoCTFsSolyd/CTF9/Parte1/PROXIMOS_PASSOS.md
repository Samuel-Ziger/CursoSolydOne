# O que fazer agora (Parte 1 fechada → Parte 2)

## Parte 1 — concluída

- [x] Acesso inicial (LFI → shell reversa)
- [x] Escalação para adalberto (credenciais/shell)
- [x] Root via CVE-2025-27591 (below symlink)
- [x] 4 flags coletadas
- [x] Coleta de artefatos (script + manual)
- [x] Documentação (resumos, análise)

---

## Agora: ir para a Parte 2

A dica da Parte 2 fala em **rede interna**, **instabilidades em servidores** e no uso do servidor comprometido como **ponte**. Você já tem:

- **Pivô:** shell root (ou adalberto) no servidor Blogo (ip-10-0-55-149).
- **Rede:** 10.0.0.0/16, gateway 10.0.0.1, vizinhos no ARP (10.0.0.2).
- **Domínio:** blogo.sy, ti@blogo.sy; no material da Parte 2 aparece **projects-blogo.sy** (header x-host no IP 44.197.245.141).

### 1. Garantir acesso estável ao pivô

- Manter shell reversa (ngrok) ou criar **túnel SSH** da sua Kali para o servidor:
  - Se tiver SSH no alvo: `ssh -D 1080 -N 0xdtc@<IP_PUBLICO_BLOGO>` → proxy SOCKS5 em 127.0.0.1:1080.
  - Se só tiver shell: usar chisel, ligação reversa persistente, etc., para depois fazer scan/recon pela rede interna a partir do pivô.

### 2. Atacar o alvo da Parte 2

O material em **Parte2/** indica:

- **IP:** 44.197.245.141 (porta 80, nginx).
- **Pista:** header **x-host: projects-blogo.sy**
- **Ações:**
  - Acessar o site (browser ou curl) e testar com `Host: projects-blogo.sy`.
  - Fazer recon no domínio (subdomínios, outros vhosts).
  - Se a plataforma der um **novo IP/alvo** para a Parte 2, fazer nmap, dirbuster/gobuster, etc., nesse alvo (de preferência via pivô se for rede interna).

### 3. Rede interna (se o CTF pedir)

- A partir do shell no servidor Blogo (como root):
  - `ip addr`, `ip route`, `ip neigh` (ou `arp -a`) — já coletado.
  - Se tiver `ping`/`nc`: varrer 10.0.0.0/24 (ou a subrede que aparecer) para descobrir outros hosts.
  - Procurar em logs e configs por outros IPs/serviços (já feito no script; rever se precisar).

### 4. AWS (se o cenário tiver EC2)

- Você está **dentro de Docker**; o metadata (169.254.169.254) costuma não responder no container.
- Se a plataforma der acesso ao **host EC2** (ex.: depois de escapar do container ou outro serviço), aí sim: pedir IAM role e credenciais ao metadata e usar na Kali para enumerar S3, EC2, Secrets Manager (conforme RESUMO_DESCOBERTAS da Parte 2).

---

## Checklist rápido

1. [ ] Ler de novo a **dica da Parte 2** e o ficheiro **Parte2/Dica-da-plataforma.txt**.
2. [ ] Abrir **Parte2/RESUMO_DESCOBERTAS.md** e seguir os “Próximos passos” (IP 44.197.245.141, projects-blogo.sy, etc.).
3. [ ] Garantir **acesso estável** ao servidor da Parte 1 (shell ou SSH) para usar como pivô.
4. [ ] Atacar o **alvo da Parte 2** (web com Host projects-blogo.sy, recon, possíveis flags/chaves).
5. [ ] Se o enunciado falar em **rede interna**, fazer varredura/exploração a partir do pivô (IPs 10.0.x.x, etc.).

Em resumo: **Parte 1 está fechada; o “o que fazer agora” é começar a Parte 2 usando o material em `Parte2/` e o servidor Blogo como ponte quando precisar.**
