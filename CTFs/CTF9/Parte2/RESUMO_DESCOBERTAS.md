# Resumo das Descobertas - Busca pela Chave do Segundo Módulo CTF

## 📊 Análise do LinpeasAdalberto.txt

### Informações da Instância EC2

- **Instance ID:** `i-02d1ebe94373a7faf`
- **Region:** `us-east-1`
- **Account ID:** `317608390162`
- **Instance Type:** `t3a.micro`
- **AMI ID:** `ami-020525ce7bc4004f0`
- **IP Público Anterior:** `3.239.25.195`
- **IP Público Novo:** `44.197.245.141`
- **IP Privado:** `3.239.25.195` (dentro da VPC)
- **Security Group:** `labs-ctfs-sg`
- **Subnet:** `10.0.0.0/16`

### Credenciais AWS EC2

O linpeas mostra que há credenciais AWS disponíveis no metadata service:

```json
{
  "Code": "Success",
  "LastUpdated": "2026-02-14T16:12:17Z",
  "Type": "AWS-HMAC",
  "AccessKeyId": "ASIA[REDACTED]",
  "SecretAccessKey": "[REDACTED]",
  "Token": "[REDACTED]",
  "Expiration": "2026-02-14T22:26:27Z"
}
```

**⚠️ IMPORTANTE:** As credenciais estão REDACTED no output do linpeas. É necessário obter as credenciais reais do metadata service da EC2.

### Ambiente

- **Container:** Docker (docker-default profile)
- **Usuário:** `adalberto`
- **Senha conhecida:** `WPcmqw16ZmzO!5paSC4`
- **Hostname:** `ip-10-0-163-175`

## 🔍 Descobertas no Novo IP (44.197.245.141)

### Scan Nmap

- **Porta 80:** Aberta (nginx 1.24.0 Ubuntu)
- **Porta 22:** Fechada (SSH)
- **Porta 443:** Fechada (HTTPS)
- **Porta 3306:** Fechada (MySQL)
- **Porta 8080:** Fechada
- **Porta 8443:** Fechada

### Headers HTTP Interessantes

- **Server:** nginx/1.24.0 (Ubuntu)
- **x-host:** `projects-blogo.sy.` ⚠️ **PISTA IMPORTANTE!**

### Página Web

- Página inicial simples ("Ambiente de Testes")
- Nenhuma palavra-chave relacionada a flags encontrada na página inicial
- Apenas `index.html` encontrado no diretório raiz

## 🎯 Estratégia para Encontrar a Chave

### 1. Obter Credenciais AWS Reais

**Opção A: Via Metadata Service (se dentro da EC2)**
```bash
# Obter IAM role
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Obter credenciais temporárias
IAM_ROLE=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/ | head -1)
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/$IAM_ROLE
```

**Opção B: Via Scripts Criados**
```bash
bash obter_aws_credenciais.sh
bash buscar_chave_segundo_modulo.sh
```

### 2. Enumerar Recursos AWS

Após obter as credenciais, enumerar:

- **S3 Buckets:** Procurar por arquivos, objetos com flags
- **Secrets Manager:** Secrets que possam conter a chave
- **Systems Manager Parameter Store:** Parâmetros que possam conter a chave
- **EC2 Tags:** Tags das instâncias que possam conter informações
- **EC2 User Data:** Scripts de inicialização que possam conter informações

### 3. Investigar o Hostname `projects-blogo.sy`

O header `x-host: projects-blogo.sy.` sugere:
- Pode haver virtual hosts configurados
- Tentar acessar com `Host: projects-blogo.sy`
- Verificar se há subdomínios relacionados

### 4. Buscar no Sistema de Arquivos

Se tiver acesso ao servidor:
- Arquivos `.pem` (chaves SSH/AWS)
- Diretórios `.aws` com credenciais
- Histórico de comandos (`~/.bash_history`)
- Arquivos temporários em `/tmp`
- Variáveis de ambiente relacionadas a AWS

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

4. **`INSTRUCOES_BUSCA_CHAVE.md`**
   - Instruções detalhadas de uso

## 🚀 Próximos Passos Recomendados

### Passo 1: Acessar o Servidor EC2

Se você não tem acesso direto, tente:
- Webshell existente (`/var/www/blogo/shell.php`)
- LFI → RCE (se ainda funcionar)
- Shell reversa existente

### Passo 2: Obter Credenciais AWS

Execute no servidor:
```bash
bash obter_aws_credenciais.sh
```

### Passo 3: Usar Credenciais para Enumerar

```bash
source aws_env.sh
aws s3 ls
aws secretsmanager list-secrets
aws ssm describe-parameters
aws ec2 describe-instances --region us-east-1
```

### Passo 4: Investigar Hostname Alternativo

```bash
curl -H "Host: projects-blogo.sy" http://44.197.245.141/
curl -H "Host: projects-blogo.sy" http://44.197.245.141/ -v
```

### Passo 5: Buscar Arquivos e Configurações

```bash
bash buscar_chave_segundo_modulo.sh
cat busca_chave_resultados.txt
```

## ⚠️ Observações Importantes

1. **Credenciais Temporárias:** As credenciais AWS expiram em `2026-02-14T22:26:27Z`. Se já expiraram, será necessário obter novas credenciais.

2. **Container Docker:** Estamos dentro de um container Docker, o que pode limitar o acesso ao metadata service. Pode ser necessário escapar do container ou acessar o host EC2.

3. **Header x-host:** O header `x-host: projects-blogo.sy.` pode indicar configuração de virtual host. Vale investigar.

4. **Tudo se Mantém:** O usuário mencionou que "tudo que foi descoberto anteriormente se mantém independente do novo IP". Isso significa que as informações do linpeas ainda são válidas.

## 📞 Informações de Contato

- **IP do Servidor:** `44.197.245.141`
- **Porta 80:** HTTP (nginx)
- **Credenciais Conhecidas:**
  - Usuário: `adalberto`
  - Senha: `WPcmqw16ZmzO!5paSC4`

---

**Status:** Análise inicial concluída. Aguardando acesso ao servidor para executar scripts e obter credenciais AWS reais.
