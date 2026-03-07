# Instruções para Buscar a Chave do Segundo Módulo CTF

## 📋 Resumo da Situação

Baseado na análise do `linpeasAdalberto.txt`:

1. **Servidor EC2 AWS identificado:**
   - Instance ID: `i-02d1ebe94373a7faf`
   - Region: `us-east-1`
   - Account ID: `317608390162`
   - IP Público anterior: `3.239.25.195`
   - **Novo IP:** `44.197.245.141`

2. **Credenciais AWS EC2:**
   - O linpeas mostra que há credenciais AWS disponíveis no metadata service
   - As credenciais estão **REDACTED** no output do linpeas
   - Tipo: `AWS-HMAC` (credenciais temporárias)
   - Expiração: `2026-02-14T22:26:27Z`

3. **Ambiente:**
   - Estamos dentro de um container Docker
   - Usuário: `adalberto`
   - Senha conhecida: `WPcmqw16ZmzO!5paSC4`

## 🎯 Objetivo

Encontrar a **chave para o segundo módulo do CTF** que deve estar relacionada às credenciais AWS ou recursos EC2.

## 🚀 Passos para Execução

### Opção 1: Executar Scripts no Servidor EC2

Se você tem acesso ao servidor EC2 (via SSH ou webshell):

```bash
# 1. Obter credenciais AWS do metadata service
bash obter_aws_credenciais.sh

# 2. Buscar chave do segundo módulo
bash buscar_chave_segundo_modulo.sh

# 3. Verificar resultados
cat busca_chave_resultados.txt
cat aws_credentials.json
```

### Opção 2: Usar AWS CLI Localmente

Se você conseguiu obter as credenciais AWS:

```bash
# Configurar credenciais
export AWS_ACCESS_KEY_ID="ASIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
export AWS_DEFAULT_REGION="us-east-1"

# Enumerar recursos
aws s3 ls
aws ec2 describe-instances
aws secretsmanager list-secrets
aws ssm describe-parameters
```

### Opção 3: Acessar Metadata Service Diretamente

Se você está dentro da instância EC2:

```bash
# Obter IAM role
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Obter credenciais temporárias
IAM_ROLE=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/ | head -1)
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/$IAM_ROLE
```

## 🔍 Onde Procurar a Chave

A chave do segundo módulo pode estar em:

1. **Recursos AWS:**
   - Buckets S3 (arquivos, objetos)
   - Secrets Manager (secrets armazenados)
   - Systems Manager Parameter Store (parâmetros)
   - Tags de instâncias EC2
   - User Data da instância EC2

2. **Arquivos no Sistema:**
   - `~/.aws/credentials`
   - `~/.aws/config`
   - Arquivos `.pem` (chaves SSH)
   - Arquivos com nomes contendo "key", "module", "módulo", "chave"

3. **Variáveis de Ambiente:**
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_SESSION_TOKEN`
   - Outras variáveis relacionadas

4. **Histórico de Comandos:**
   - `.bash_history`
   - Logs do sistema
   - Arquivos temporários

## 📝 Scripts Criados

1. **`obter_aws_credenciais.sh`**
   - Obtém credenciais AWS do metadata service
   - Salva em `aws_credentials.json` e `aws_env.sh`

2. **`obter_credenciais_aws.py`**
   - Versão Python para obter credenciais
   - Enumera recursos AWS (S3, EC2, Secrets Manager, SSM)

3. **`buscar_chave_segundo_modulo.sh`**
   - Busca completa por chaves e credenciais
   - Verifica arquivos, variáveis de ambiente, histórico
   - Salva resultados em `busca_chave_resultados.txt`

## ⚠️ Importante

- As credenciais AWS são **temporárias** e expiram em `2026-02-14T22:26:27Z`
- Se você estiver em um container Docker, o metadata service pode não estar acessível diretamente
- Nesse caso, você precisa escapar do container ou acessar o host EC2

## 🔗 Próximos Passos

1. **Se você tem acesso ao servidor:**
   - Execute os scripts acima
   - Analise os resultados
   - Use as credenciais para enumerar recursos AWS

2. **Se você não tem acesso direto:**
   - Tente obter acesso via:
     - Webshell (`/var/www/blogo/shell.php`)
     - LFI → RCE
     - Shell reversa existente

3. **Após obter credenciais:**
   - Enumere todos os recursos AWS
   - Procure por flags, chaves, ou informações relacionadas ao segundo módulo
   - Verifique tags, user-data, e secrets

## 📞 Informações de Contato/Recursos

- IP do servidor: `44.197.245.141`
- Porta 80: HTTP (nginx)
- Credenciais conhecidas:
  - Usuário: `adalberto`
  - Senha: `WPcmqw16ZmzO!5paSC4`

---

**Boa sorte na busca pela chave! 🎯**
