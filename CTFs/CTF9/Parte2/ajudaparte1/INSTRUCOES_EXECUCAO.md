# Instruções de Execução - Parte 1 CTF9

## 🎯 Objetivo
Encontrar Flag 4 e investigar movimento lateral no servidor 44.197.173.254

## 📋 Scripts Criados

### Scripts Individuais

1. **script_01_leitura_flag.sh**
   - Lê `/flag.txt` encontrado
   - Verifica outras flags possíveis
   - Verifica diretórios home

2. **script_02_rede_interna.sh**
   - Interfaces de rede
   - Rotas e ARP cache
   - Conexões estabelecidas
   - Processos de rede

3. **script_03_chaves_ssh.sh**
   - Busca chaves SSH
   - Verifica known_hosts
   - Busca credenciais

4. **script_04_movimento_lateral.sh**
   - Processos SSH ativos
   - Túneis e port forwarding
   - Logs de conexões
   - Configurações de rede

5. **script_05_busca_completa.sh**
   - Busca todas as flags
   - Busca LightBringers
   - Busca referências solyd

### Script Master

**EXECUTAR_TODOS.sh** - Executa todos os scripts em sequência

## 🚀 Como Executar

### Opção 1: Executar Todos (RECOMENDADO)

No servidor, execute:

```bash
# Fazer upload dos scripts para o servidor (via webshell ou shell reversa)
# Depois executar:

bash EXECUTAR_TODOS.sh
```

### Opção 2: Executar Individualmente

```bash
# Script 1 - Flag
bash script_01_leitura_flag.sh

# Script 2 - Rede
bash script_02_rede_interna.sh

# Script 3 - SSH
bash script_03_chaves_ssh.sh

# Script 4 - Movimento Lateral
bash script_04_movimento_lateral.sh

# Script 5 - Busca Completa
bash script_05_busca_completa.sh
```

## 📤 Upload dos Scripts

### Via Webshell

```bash
# Criar os scripts diretamente no servidor usando nano ou echo
nano script_01_leitura_flag.sh
# Colar conteúdo e salvar
```

### Via Shell Reversa

```bash
# No seu terminal local:
cat script_01_leitura_flag.sh | base64

# No servidor remoto:
echo "BASE64_CONTENT" | base64 -d > script_01_leitura_flag.sh
chmod +x script_01_leitura_flag.sh
bash script_01_leitura_flag.sh
```

## 📊 Resultados

Os scripts salvam resultados em arquivos `.txt` quando executados via `EXECUTAR_TODOS.sh`.

## ⚠️ Importante

- Você está como usuário `adalberto`
- Webshell disponível em `/var/www/blogo/shell.php`
- Flag encontrada em `/flag.txt` (precisa ler)
- Investigar rede interna para movimento lateral

---

**Execute os scripts e me passe os resultados!**
