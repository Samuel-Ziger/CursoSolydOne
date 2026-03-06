# Investigação Completa - Parte 1 CTF9

## 🎯 Objetivo
Encontrar Flag 4 e investigar movimento lateral no servidor 44.197.173.254

## 📋 Script Único

**investigacao_completa.sh** - Script único que executa TODAS as investigações

## 🚀 Como Executar

### No Servidor (como usuário adalberto)

```bash
# Tornar executável
chmod +x investigacao_completa.sh

# Executar
bash investigacao_completa.sh
```

### Resultados

Os resultados serão salvos automaticamente em: **investigacao_resultados.txt**

Para visualizar:
```bash
cat investigacao_resultados.txt
```

## 📤 Upload do Script

### Opção 1: Criar diretamente no servidor (RECOMENDADO)

```bash
# No servidor, usando nano:
nano investigacao_completa.sh
# Colar todo o conteúdo do script
# Salvar: Ctrl+X, Y, Enter
chmod +x investigacao_completa.sh
bash investigacao_completa.sh
```

### Opção 2: Via Base64

```bash
# No seu terminal local:
cat investigacao_completa.sh | base64 -w 0

# No servidor remoto:
echo "BASE64_CONTENT_AQUI" | base64 -d > investigacao_completa.sh
chmod +x investigacao_completa.sh
bash investigacao_completa.sh
```

## 🔍 O que o Script Faz

O script executa 5 seções completas de investigação:

1. **Seção 1: Flags e Informações Básicas**
   - Lê `/flag.txt`
   - Busca todas as flags
   - Verifica diretórios home
   - Busca LightBringers e solyd

2. **Seção 2: Rede Interna**
   - Interfaces de rede
   - Rotas e ARP cache
   - Conexões estabelecidas
   - Processos de rede

3. **Seção 3: Chaves SSH e Credenciais**
   - Busca chaves SSH
   - Verifica known_hosts
   - Busca credenciais

4. **Seção 4: Movimento Lateral**
   - Processos SSH ativos
   - Túneis e port forwarding
   - Logs de conexões
   - Configurações de rede

5. **Seção 5: Histórico e Logs**
   - Histórico bash completo
   - Logs do sistema
   - Busca por flags em logs

## ⚠️ Importante

- Você está como usuário `adalberto`
- Webshell disponível em `/var/www/blogo/shell.php`
- Flag encontrada em `/flag.txt` (precisa ler)
- Investigar rede interna para movimento lateral

---

**Execute o script e me passe o arquivo `investigacao_resultados.txt`!**
