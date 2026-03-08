# CTF9 Parte 2 – Reconhecimento no alvo 44.197.245.141

## Alvo
- **IP:** 44.197.245.141  
- **Host no /etc/hosts:** projects-blogo.sy  

## Resumo do que foi feito

### 1. Scan de portas (nmap)
- **80/tcp** – aberta – **HTTP** (nginx 1.24.0 Ubuntu)  
- 25, 137, 138 – filtradas  
- Demais portas testadas – fechadas  

### 2. Serviço HTTP
- **VHost:** o servidor responde com a página “Ambiente de Testes de Projetos” quando o header é **Host: projects-blogo.sy**.  
- **Página única:** HTML estático (index.html), título “Ambiente de Testes”, texto sobre uso exclusivo do setor de TI da Blogo, validação de builds/artefatos.  
- **Header de resposta:** `X-Host: projects-blogo.sy`.  
- **Sem flag no conteúdo:** não há `Solyd{...}` no corpo da página, em comentários HTML nem em meta tags.  

### 3. Caminhos e parâmetros testados (todos 404 ou mesma página)
- `/projetos`, `/projects`, `/builds`, `/artefatos`, `/homolog`, `/ti`, `/admin`, `/api`, `/login`, `/config`, `/backup`, `/shell.php`, `/noticias.php`, `/flag.txt`, `/robots.txt`, `/sitemap.xml`, `/.git/HEAD`, `/.env`, `/joao-cleber`, `/lightbringers`, `/rede-interna`, `/flag1` a `/flag4`, variações com barra final, case e encoding.  
- Parâmetros: `?page=`, `?file=`, `?path=`, `?debug=1`, `?internal=1`, etc. – não mudam o conteúdo (mesmo tamanho ~2711 bytes).  
- Host alternativos: vários Host (www, blogo.sy, subdomínios flag1–4, etc.) – mesma resposta 200, mesmo tamanho.  

### 4. Outros testes
- LFI com parâmetros típicos: resposta idêntica à da raiz (não há inclusão de arquivo).  
- User-Agent e Referer “internos”: sem mudança de conteúdo.  
- OPTIONS/PUT: 405 e 405.  
- Host vazio: 400 Bad Request (nginx).  

## Conclusão até o momento
- **Nenhuma das 4 flags foi encontrada.**  
- O que se vê é um único serviço (HTTP na 80) servindo uma única página estática, sem outros paths ou parâmetros que alterem a resposta.  

## Próximos passos sugeridos (sem brute force)
1. **Confirmar com a plataforma** se o cenário da parte 2 está ativo (instabilidades citadas na dica podem afetar disponibilidade).  
2. **Rever a descrição do desafio** na plataforma: às vezes há menção a “primeiro acesso”, “token” ou “link” específico para esta etapa.  
3. **Repetir testes em outro horário** – algum path ou serviço pode ser ativado só em certos momentos.  
4. **Verificar se há outro IP/host** para a “rede interna” (ex.: outro endereço liberado após resolver algo na página).  
5. **Manter credenciais da parte 1** (ex.: adalberto / WPcmqw16ZmzO!5paSC4) para uso caso apareça login ou SSH em outro serviço.  

## Comandos úteis para retomar
```bash
# Acesso à página
curl -s -H "Host: projects-blogo.sy" "http://44.197.245.141/"

# Verificar headers
curl -sI -H "Host: projects-blogo.sy" "http://44.197.245.141/"
```

---
*Reconhecimento realizado em 06/03/2026. Alvo: 44.197.245.141 (projects-blogo.sy).*
