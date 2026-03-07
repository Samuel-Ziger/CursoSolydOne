# Resumo da exploração (exploracao_20260306_232154.txt)

Principais achados da execução do script na **Parte 1** — o que usar na **Parte 2** (44.197.245.141 / projects-blogo.sy).

---

## 1. Domínio e e-mail da TI — **blogo.sy**

No **noticias.php** (linhas 372–373):

```php
if (isset($_GET['text']) && $_GET['text'] === '') {
   echo "Erro. Favor avisar a equipe de TI pelo email ti@blogo.sy";
   exit;
}
if (isset($_GET['text'])) {
  include("files/" . $_GET['text']);
}
```

- **Domínio:** **blogo.sy**
- **E-mail TI:** **ti@blogo.sy**
- Na Parte 2 você já usa **projects-blogo.sy**. Vale testar outros Host na mesma máquina, por exemplo:
  - **ti.blogo.sy**
  - **www.blogo.sy**
  - **blogo.sy**
  - **noticias.blogo.sy**

---

## 2. LFI em noticias.php — parâmetro `text`

- **Parâmetro:** `?text=`
- **Lógica:** `include("files/" . $_GET['text']);`
- Se `text` for vazio → mensagem com **ti@blogo.sy**.
- Path traversal: ex. `?text=../config/config.php` ou `?text=../../../etc/passwd` (conforme já explorado na Parte 1).
- Arquivos em **/var/www/blogo/files/**:
  - **settings.json** (89 bytes) — no grep apareceu `"username": "blogodb"` (pode ter mais dados).
  - **test.php** (55 bytes, dono mysql).
  - **test.txt** (5 bytes).

Na Parte 1, para ler **settings.json** via LFI (sem traversal):  
`noticias.php?text=settings.json` (se o script incluir como PHP, pode dar erro; em alguns casos dá para ler como texto ou via log/error).

---

## 3. Rede (Parte 1)

| Item        | Valor |
|------------|--------|
| IP do host | **10.0.208.92** e **172.17.0.1** |
| Gateway (ARP) | **10.0.0.1** (ens5) |
| DNS search | **ec2.internal** |
| MySQL hostname | **ip-10-0-208-92** |

Logs Apache (access/error) não tinham nada em “projects-blogo”, “10.0.” ou “internal” nas últimas linhas.

---

## 4. Apache — /files/ só local

```apache
<Directory "/var/www/blogo/files">
    Require local
</Directory>
```

Ou seja: **/files/** só acessível por localhost; na prática, inclusão via LFI (parâmetro `text`) ou pela shell.

---

## 5. MySQL (Parte 1)

- **hostname:** ip-10-0-208-92  
- **datadir:** /var/lib/mysql/  
- Apenas **information_schema** e **performance_schema**; usuário **blogodb** com privilégio USAGE (já conhecido).

---

## 6. Arquivos sensíveis

- **config.php:** host 127.0.0.1, name/user **blogodb**, senha conhecida.
- **files/settings.json:** contém pelo menos `"username": "blogodb"`; vale ler o arquivo inteiro (por LFI ou shell) para ver se há URL, host ou senha para a Parte 2.

---

## 7. O que fazer na Parte 2 com isso

1. **Host headers** em **44.197.245.141**:
   - **Host: projects-blogo.sy** (já testado)
   - **Host: ti.blogo.sy**
   - **Host: www.blogo.sy**
   - **Host: blogo.sy**
   - **Host: noticias.blogo.sy**

2. **Credenciais:** manter **blogodb** / **adalberto** com **WPcmqw16ZmzO!5paSC4** em qualquer login (web, SSH, painel) na Parte 2.

3. **Paths:** continuar testando paths como **/ti**, **/projetos**, **/noticias**, **/files** (e variantes) na Parte 2, com os Host acima.

4. **Na Parte 1 (se ainda tiver acesso):** ler o conteúdo completo de **/var/www/blogo/files/settings.json** (por exemplo `cat /var/www/blogo/files/settings.json`) e procurar URL, host ou referência a **projects-blogo**, **ti.blogo.sy** ou rede interna.

---

*Resumo gerado a partir de: exploracao_20260306_232154.txt*
