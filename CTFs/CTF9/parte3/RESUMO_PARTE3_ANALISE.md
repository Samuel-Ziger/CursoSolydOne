# Parte 3 CTF9 – Resumo da análise (IP 3.228.11.37)

## Situação do alvo
- **IP:** 3.228.11.37 (ec2-3-228-11-37.compute-1.amazonaws.com)
- **Porta aberta:** 22/tcp (SSH)
- **Serviço:** OpenSSH 9.6p1 Ubuntu 3ubuntu13.14
- **Autenticação:** `publickey` e `password`
- **Porta 58000:** filtered (possível serviço interno)
- **Dica (dicadaplataforma):** alvo = **lb-test**; assinatura **F3uH3Ad**

## O que já foi feito (manual + esta análise)

1. **Reconhecimento**
   - Nmap básico e -A, scripts SSH (algoritmos, hostkey, auth-methods)
   - Varredura de portas (-p-): só 22 aberta, 25/137/138/58000 filtered
   - ssh-audit (fingerprints, algoritmos, Terrapin)
   - Teste de auth: `PreferredAuthentications=none` → negado (publickey,password)

2. **Tentativas de acesso SSH**
   - Brute force com **kali** (e provavelmente lista genérica): 2910 tentativas sem sucesso (nmap ssh-brute)
   - Hydra com **lb-test** + várias wordlists:
     - `passwords_ctf.txt` (termos do CTF: F3uH3Ad, Blogo, lightbringers, WPcmqw16ZmzO!5paSC4, etc.)
     - `rockyou_small.txt` (timeout antes de terminar)
     - Usuários testados: **lb-test**, blogodb, adalberto, root, ubuntu, ec2-user, admin, lightbringers
   - Credenciais da Parte 1 (blogodb/adalberto + WPcmqw16ZmzO!5paSC4) testadas → **não funcionam** neste servidor

3. **Vulnerabilidades avaliadas**
   - **CVE-2024-6387 (regreSSHion):** OpenSSH 9.6p1 é da faixa afetada, mas o pacote Ubuntu é **3ubuntu13.14**; a correção da Ubuntu foi em 3ubuntu13.3. Como 13.14 > 13.3, o servidor **provavelmente já está corrigido**.
   - **CVE-2024-6352:** bypass de ChrootDirectory; só ajuda **após** ter sessão dentro de chroot, não dá acesso inicial.
   - **CVE-2018-15473 (user enum):** OpenSSH 9.6 não é vulnerável.

## Conclusão atual
- Ainda **sem credenciais válidas** para SSH.
- Único vetor plausível continua sendo **senha fraca** ou **chave SSH** vazada em outro passo do CTF (ex. Parte 2, plataforma ou arquivo do desafio).

## Próximos passos sugeridos

1. **Parte 2**
   - Você comentou 0/4 flags na Parte 2. Se a Parte 3 depender de algo obtido na Parte 2 (credencial, chave, user data de EC2, objeto em S3), vale retomar a Parte 2 e procurar:
     - Credenciais AWS (metadata, scripts)
     - Chaves SSH ou menção a “lb-test” / “3.228.11.37”
     - Arquivos ou notas com usuário/senha para “servidor de testes” ou “lb-test”

2. **Wordlists e brute force**
   - Testar **lb-test** com listas maiores (ex.: top 10k–100k do rockyou, listas de CTF/Solyd).
   - Se a plataforma permitir, tentar **user enum** com outras listas (ex.: xato_net_usernames) e depois atacar só os usuários que “existirem” (em versões antigas de SSH ou em outros serviços).

3. **Plataforma / enunciado**
   - Conferir se a plataforma do CTF (Solyd) entrega algo para a Parte 3 (token, senha, arquivo, “dica extra” após entregar flags da Parte 2).

4. **Manter arquivos úteis**
   - `users_expanded.txt` e `passwords_ctf.txt` estão na pasta para novos testes com Hydra ou outras ferramentas.

---
*Gerado a partir de achadosmanual.txt, dicadaplataforma, e testes realizados na análise da Parte 3.*
