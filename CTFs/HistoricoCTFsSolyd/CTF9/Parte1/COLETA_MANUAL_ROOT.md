# Coleta manual como root (Parte 1)

Resumo do que você viu explorando como root no servidor (ip-10-0-55-149).

---

## Flag (4ª)

- **Arquivo:** `/root/flag.txt`
- **Conteúdo:** `Solyd{U$G0T$R007%Congrats!!!!}`

---

## Ambiente

- **Container Docker:** existe `/` com `.dockerenv` → você está **dentro de um container**, não no host EC2 direto.
- **Rust/rustup:** instalado em `/root/.rustup` (toolchain stable-x86_64) — ambiente de desenvolvimento, provavelmente usado para compilar o `below`. Nada sensível para ataque.
- **Ferramentas ausentes:** no container não têm `ss` nem `netstat`; para conexões use `/proc/net/tcp` (como no script de coleta).

---

## SSH / pivô

- **`/root/.ssh/`** — diretório existe mas está **vazio** (sem `authorized_keys`, sem chaves privadas).
- **`/home/ubuntu/.ssh/`** — **não existe**.
- Conclusão: nesse host não há chaves SSH para pivotar para outros servidores; a Parte 2 terá de usar outro caminho (rede, AWS, etc.).

---

## Usuários e homes

- **/home/adalberto** — dono adalberto (você já usou para o exploit).
- **/home/ubuntu** — existe; só ficheiros padrão (.bash_logout, .bashrc, .profile), sem `.ssh` nem nada sensível.

---

## AWS metadata

- Você tentou `curl 169.254.169.254/...` (IAM credentials). Dentro de **Docker**, esse endpoint costuma não responder ou estar bloqueado; as credenciais IAM ficam no **host** EC2, não no container. Para credenciais AWS na Parte 2, é preciso acesso ao host (escapar do container ou outro serviço no host).

---

## Outros ficheiros em /root

| Ficheiro          | Utilidade |
|-------------------|-----------|
| `.bash_history`   | Pode ter comandos úteis — vale `cat` para rever. |
| `.mysql_history`  | Vazio (1 byte). |
| `.wget-hsts`      | Só cache do wget (raw.githubusercontent.com) — irrelevante. |
| `flag.txt`        | 4ª flag. |

---

## Ficheiros na raiz (/)

- **/flag.txt** (30 bytes, Jan 15) — outra flag ou placeholder; o conteúdo “oficial” da 4ª flag é o de `/root/flag.txt`.
- **/exploracao_20260310_003237.txt** — saída do seu script de exploração (já você tem cópia em “tudo que coletei com o script.txt”).
- **/explorar_parte1.0.sh** — o script que rodou como root.

---

## Resumo para a Parte 2

- Está em **Docker** → AWS metadata provavelmente só no host.
- **Nenhuma chave SSH** em root nem em ubuntu → pivô por SSH terá de ser a partir do seu Kali (túnel até este host) ou por outros meios.
- Rede e credenciais locais (MySQL, etc.) continuam a vir da coleta do script; esta exploração manual confirma que não há “bónus” em SSH/keys no root.
