# Comandos Rápidos - Busca Flag 4

## 🚀 Comandos para Executar Imediatamente

### 1. Busca por Flags (PRIORIDADE MÁXIMA)

```bash
# Busca completa
find / -name "*flag*" -type f 2>/dev/null
find / -name "*Flag*" -type f 2>/dev/null
find / -name "*FLAG*" -type f 2>/dev/null

# Busca por LightBringers
find / -name "*LightBringers*" -o -name "*lightbringers*" 2>/dev/null
grep -r "LightBringers" /home /var/www /opt /tmp /root 2>/dev/null

# Busca por "solyd" em arquivos
grep -r "solyd" /home /var/www /opt /tmp 2>/dev/null | grep -i flag
```

### 2. Rede Interna (CRÍTICO para Parte 2)

```bash
# Interfaces e IPs
ip a
ip route
arp -a
cat /proc/net/arp

# Conexões estabelecidas
ss -antp | grep ESTABLISHED
netstat -antup | grep ESTABLISHED
lsof -i
```

### 3. Chaves SSH (Pode levar à Parte 2)

```bash
# Buscar chaves
find / -name "id_rsa*" 2>/dev/null
find / -name "*.pem" 2>/dev/null
find / -name "*.key" 2>/dev/null

# Known hosts (mostra onde conectou)
cat ~/.ssh/known_hosts 2>/dev/null
cat /home/*/.ssh/known_hosts 2>/dev/null
cat /root/.ssh/known_hosts 2>/dev/null
```

### 4. Histórico de Comandos

```bash
# Ver o que foi executado
cat ~/.bash_history
cat /home/*/.bash_history 2>/dev/null
cat /root/.bash_history 2>/dev/null

# Buscar comandos relacionados a flags/SSH/rede
cat ~/.bash_history | grep -E "flag|ssh|ip|route|arp"
```

### 5. Diretórios Específicos

```bash
# /opt
ls -la /opt/
find /opt -name "*flag*" 2>/dev/null

# /tmp
ls -la /tmp/ | head -30
find /tmp -name "*flag*" 2>/dev/null

# /var/log
grep -r "flag\|Flag\|FLAG" /var/log/ 2>/dev/null | head -20
```

### 6. Processos e Túneis

```bash
# Ver processos suspeitos
ps aux | grep -E "ssh|socat|nc|tunnel" | grep -v grep

# Ver conexões de rede
ss -antp
netstat -antup
```

## 🎯 Comandos Combinados (Executar Tudo de Uma Vez)

```bash
echo "=== BUSCA FLAGS ===" && \
find / -name "*flag*" -type f 2>/dev/null && \
echo "" && echo "=== REDE INTERNA ===" && \
ip a && ip route && arp -a && \
echo "" && echo "=== CONEXÕES ===" && \
ss -antp | grep ESTABLISHED && \
echo "" && echo "=== CHAVES SSH ===" && \
find / -name "id_rsa*" 2>/dev/null && \
echo "" && echo "=== HISTÓRICO ===" && \
cat ~/.bash_history | tail -20
```

## 📝 Salvar Resultados

```bash
# Salvar tudo em arquivo
{
echo "=== FLAGS ==="
find / -name "*flag*" -type f 2>/dev/null
echo ""
echo "=== REDE ==="
ip a
ip route
arp -a
echo ""
echo "=== CONEXÕES ==="
ss -antp | grep ESTABLISHED
echo ""
echo "=== SSH ==="
find / -name "id_rsa*" 2>/dev/null
cat ~/.ssh/known_hosts 2>/dev/null
} > /tmp/investigacao_flag4.txt 2>&1

# Depois baixar o arquivo
cat /tmp/investigacao_flag4.txt
```

---

**Execute estes comandos no servidor e me passe os resultados!**
