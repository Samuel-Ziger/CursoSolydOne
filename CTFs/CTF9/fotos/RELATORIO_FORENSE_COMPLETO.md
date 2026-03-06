# Relatório Forense Completo - CTF9 Fotos
## Análise de Esteganografia e Dados Ocultos

**Data:** 27 de Fevereiro de 2026  
**Arquivos Analisados:** `aetherpharma.png`, `festas-ano-novo.png`  
**Objetivo:** Extrair flags no formato `solyd{...}` e informações ocultas

---

## 📋 Sumário Executivo

Foram realizadas análises forenses completas em duas imagens PNG, incluindo:
- Análise de metadados (EXIF, XMP, comentários)
- Análise hexadecimal profunda
- Extração de strings
- Análise esteganográfica (LSB, bit-planes, canais RGB)
- Comparação entre imagens (XOR, subtração)
- Busca por arquivos embutidos
- Análise de criptografia e decodificação

**Status:** Análise em andamento - Dados promissores encontrados, mas flag ainda não extraída completamente.

---

## 🔍 1. Análise de Metadados

### 1.1 Informações Básicas dos Arquivos

| Arquivo | Tamanho | Dimensões | Tipo | Hash MD5 |
|---------|---------|-----------|------|---------|
| `aetherpharma.png` | 312,917 bytes | 700x330 | PNG RGB 8-bit | e6981c82e514efb6754cd08a36dd386e |
| `festas-ano-novo.png` | 466,106 bytes | 700x330 | PNG RGB 8-bit | e091f174271a73b992368ad670ae7aff |

### 1.2 Metadados EXIF

**Resultado:** Nenhum metadado suspeito encontrado.
- Sem comentários customizados
- Sem tags XMP suspeitas
- Sem dados em campos de texto
- Datas de modificação normais

### 1.3 Estrutura PNG

**aetherpharma.png:**
- 7 chunks PNG válidos
- 5 chunks IDAT (compressão Deflate)
- Compressão: 54.8%

**festas-ano-novo.png:**
- 10 chunks PNG válidos
- 8 chunks IDAT (compressão Deflate)
- Compressão: 32.7%

**Observação:** `festas-ano-novo.png` tem mais chunks IDAT, indicando mais dados comprimidos.

---

## 🔬 2. Análise Hexadecimal Profunda

### 2.1 Headers e Assinaturas

**Ambas as imagens:**
- Header PNG válido: `89 50 4E 47 0D 0A 1A 0A`
- Chunk IHDR válido
- Chunk IEND encontrado corretamente
- **Nenhum dado após IEND** (arquivos não têm dados concatenados)

### 2.2 Busca por Arquivos Embutidos

**Ferramentas utilizadas:**
- `binwalk`: Nenhum arquivo embutido detectado
- `file`: Apenas PNG válidos
- Busca manual por assinaturas (ZIP, PDF, RAR, 7z): **Nenhum encontrado**

### 2.3 Análise de Entropia

**aetherpharma.png:**
- Entropia total: **7.9834** (máximo: 8.0)
- 306 blocos com entropia > 7.5 (alta entropia)

**festas-ano-novo.png:**
- Entropia total: **7.9834** (máximo: 8.0)
- 455 blocos com entropia > 7.5 (alta entropia)

**Interpretação:** Alta entropia é esperada em dados comprimidos (PNG usa Deflate), mas pode também indicar dados criptografados.

---

## 📝 3. Extração de Strings

### 3.1 Strings ASCII

**Método:** `strings -a -n 4`

**Resultado:** Nenhuma string contendo "solyd", "flag", "ctf" encontrada diretamente nos arquivos.

### 3.2 Busca por Padrões

- Base64: Nenhum padrão válido encontrado
- Hex: Nenhum padrão suspeito
- Unicode: Nenhuma string oculta encontrada

---

## 🎨 4. Análise Esteganográfica

### 4.1 Ferramenta zsteg - Descobertas Importantes

**aetherpharma.png:**
```
b2,b,lsb,xy         .. file: OpenPGP Public Key ⚠️
b4,r,lsb,xy         .. text: "wvgfvvfeUeUTDUfeV"
b4,g,lsb,xy         .. text: "4VffUU3EwQ"
b4,b,lsb,xy         .. text: "uTCEUUT1"
b4,bgr,lsb,xy       .. text: "GswFdfEUx"
```

**festas-ano-novo.png:**
```
b3,rgb,msb,xy       .. file: zlib compressed data ⚠️
b4,r,lsb,xy         .. text: "\"ES|R3S'"
b4,g,lsb,xy         .. text: "!1\"!!B4?Db2"
b4,b,lsb,xy         .. text: "S3DCDDDTUxu"
```

### 4.2 Dados Extraídos

#### 4.2.1 OpenPGP Public Key (aetherpharma.png b2,b,lsb)
- **Arquivo:** `pubkey.asc` (57,750 bytes)
- **Status:** Arquivo corrompido/inválido
- **Análise GPG:** Pacotes com versão desconhecida
- **Tentativas de correção:** 7 versões com XOR aplicado, nenhuma válida
- **Observação:** Pode conter chave pública ou privada fragmentada

#### 4.2.2 Zlib Compressed Data (festas-ano-novo.png b3,rgb,msb)
- **Arquivo:** `payload.zlib` (259,875 bytes)
- **Header:** `78 3F` (válido matematicamente: `(0x78*256 + 0x3F) % 31 == 0`)
- **Status:** **NÃO descomprime** (erro: "Error 2 while decompressing data")
- **32 headers zlib válidos** encontrados em diferentes offsets
- **Padrões repetitivos detectados:**
  - `6ddbb66d`: 2,243 ocorrências
  - `dbb66ddb`: 2,218 ocorrências
  - `b66ddbb6`: 2,188 ocorrências

#### 4.2.3 Textos nos Bit Planes b4

**aetherpharma.png:**
- `b4,r,lsb`: `wvgfvvfeUeUTDUfeV`
- `b4,g,lsb`: `4VffUU3EwQ`
- `b4,b,lsb`: `uTCEUUT1`
- `b4,bgr,lsb`: `GswFdfEUx`

**festas-ano-novo.png:**
- `b4,r,lsb`: `"ES|R3S'`
- `b4,g,lsb`: `!1"!!B4?Db2`
- `b4,b,lsb`: `S3DCDDDTUxu`

**Características:**
- Entropia: 4.61 (baixa para chave criptográfica)
- Contêm caracteres especiais (`|`, `"`, `!`)
- Possível Base85 ou codificação customizada
- Podem ser chaves XOR fragmentadas

### 4.3 Análise LSB Completa

**Métodos testados:**
- LSB de todos os canais RGB
- LSB de canais isolados (R, G, B)
- Bit planes 0-7
- LSB do resultado XOR entre imagens
- LSB da diferença entre imagens

**Resultado:** Nenhuma flag encontrada diretamente no LSB.

### 4.4 Comparação Entre Imagens

**Operações testadas:**
- XOR pixel a pixel
- Subtração absoluta
- Diferença absoluta
- Operações bitwise (AND, OR)

**Resultado:** Diferenças significativas encontradas (max diff: 252), mas nenhuma flag extraída.

---

## 🔐 5. Análise de Criptografia e Decodificação

### 5.1 Tentativas de Decodificação dos Textos b4

**Métodos testados:**
- Base64: Não decodificou corretamente
- Base32: Não decodificou corretamente
- Base85/ASCII85: Erro (caracteres inválidos)
- ROT13: Sem resultados úteis
- XOR com "aether": Sem resultados
- XOR com "festas": Sem resultados
- XOR entre textos correspondentes: Sem resultados
- SHA256 dos textos como chave: Não funcionou

### 5.2 Tentativas de Correção do Payload.zlib

#### 5.2.1 Verificação do Header Zlib

**Descoberta importante:**
- Header `78 3F` **é válido** matematicamente
- `(0x78 * 256 + 0x3F) % 31 == 0` ✅
- Mas a descompressão falha, indicando possível criptografia adicional

#### 5.2.2 Tentativas de Correção

**Métodos testados:**
1. **Bit Rotation (1-7 bits):** Nenhum gerou zlib válido
2. **XOR no header:** Headers corrigidos, mas não descomprimiu
3. **XOR global:** Testadas 9 chaves possíveis, nenhuma funcionou
4. **XOR apenas a partir do byte 2:** Headers válidos, mas erros na descompressão
5. **Raw Deflate (-15):** Não funcionou
6. **Busca em outros offsets:** 32 headers válidos encontrados, nenhum descomprimiu
7. **XOR com padrões repetitivos:** Não funcionou
8. **XOR com textos b4:** Não gerou header válido
9. **XOR com SHA256 dos textos:** Não funcionou
10. **XOR com pubkey como keystream:** Não funcionou

### 5.3 Tentativas de Correção do Pubkey.asc

**Métodos testados:**
- XOR com chaves 0x3E, 0xA3, 0xE5, 0x79, 0x26, 0xE4, 0xA2, 0x1F, 0x42, 0x84, 0xC6
- Nenhuma versão gerou chave GPG válida
- Nenhuma string "solyd" encontrada nos pubkeys transformados

---

## 🧬 6. Análise Avançada - Reextração de Dados

### 6.1 Reextração do Bit Plane b3,rgb,msb

**Métodos testados:**
- Diferentes ordens RGB (RGB, RBG, GRB, GBR, BRG, BGR)
- Diferentes ordens de leitura de pixels (normal, reverse_x, reverse_y, reverse_both)
- Bit planes 3 e 7 (MSB)

**Resultado:** Nenhum header zlib válido encontrado nas reextrações.

### 6.2 Análise dos Padrões Repetitivos

**Padrões encontrados no payload.zlib:**
```
6ddbb66d: 2,243 ocorrências
dbb66ddb: 2,218 ocorrências  
b66ddbb6: 2,188 ocorrências
```

**Interpretação:**
- Padrões muito repetitivos sugerem possível XOR com chave curta
- Padrão pode ser a própria chave ou resultado da criptografia
- Tentativa de usar padrão como chave XOR: Não funcionou

---

## 📊 7. Estatísticas e Métricas

### 7.1 Arquivos Criados Durante Análise

| Tipo | Quantidade | Tamanho Total |
|------|------------|---------------|
| Arquivos payload | 0 | - |
| Arquivos pubkey | 8 | ~462 KB |
| Arquivos de análise | 5+ | ~500 KB |
| Imagens processadas | 6 | ~2 MB |

### 7.2 Métodos de Análise Utilizados

- ✅ Análise de metadados (EXIF, XMP)
- ✅ Análise hexadecimal
- ✅ Extração de strings
- ✅ Análise LSB completa
- ✅ Análise de bit planes
- ✅ Comparação entre imagens
- ✅ Busca por arquivos embutidos
- ✅ Análise de entropia
- ✅ Tentativas de decodificação (Base64, Base32, Base85)
- ✅ Tentativas de correção com XOR
- ✅ Tentativas de correção com bit rotation
- ✅ Tentativas de correção com raw deflate
- ✅ Reextração com diferentes ordens RGB
- ✅ Análise de padrões repetitivos

---

## 🎯 8. Descobertas Principais

### 8.1 Descobertas Confirmadas

1. **OpenPGP Public Key** escondido em `aetherpharma.png` (bit plane b2,b,lsb)
2. **Zlib Compressed Data** escondido em `festas-ano-novo.png` (bit plane b3,rgb,msb)
3. **Textos suspeitos** nos bit planes b4 de ambas as imagens
4. **32 headers zlib válidos** em diferentes offsets do payload
5. **Padrões repetitivos** no payload.zlib sugerindo possível XOR

### 8.2 Hipóteses Fortes

1. **Pipeline provável:**
   - Imagem A (`aetherpharma.png`) → Chave pública/privada
   - Imagem B (`festas-ano-novo.png`) → Mensagem criptografada + comprimida
   - Textos b4 → Chave de transformação ou seed

2. **O payload.zlib precisa de descriptografia antes de descomprimir:**
   - Header válido mas não descomprime
   - Padrões repetitivos indicam possível XOR
   - Textos b4 podem ser a chave

3. **O pubkey pode estar corrompido intencionalmente:**
   - Precisa de transformação adicional
   - Pode precisar da mesma chave do payload

---

## ⚠️ 9. Limitações e Desafios

### 9.1 Desafios Enfrentados

1. **Payload.zlib não descomprime:**
   - Header válido matematicamente
   - Mas erro na descompressão
   - Possível criptografia adicional

2. **Pubkey.asc corrompido:**
   - Detectado como OpenPGP mas inválido
   - Múltiplas tentativas de correção falharam

3. **Textos b4 não decodificam:**
   - Não são Base64/Base32 válidos
   - Base85 falha
   - Podem precisar de processamento diferente

### 9.2 Métodos Não Testados (Ainda)

1. Combinação específica dos textos b4
2. Uso dos textos b4 como chave para descriptografar payload
3. Múltiplas camadas de transformação
4. Outros métodos de esteganografia (F5, OutGuess, etc.)
5. Análise de frequência dos padrões repetitivos

---

## 🔮 10. Próximos Passos Recomendados

### 10.1 Prioridade Alta

1. **Investigar os padrões repetitivos:**
   - Análise de frequência detalhada
   - Tentar usar como chave XOR de diferentes formas
   - Verificar se são resultado de XOR conhecido

2. **Combinar payload + pubkey:**
   - Tentar usar pubkey como keystream de forma diferente
   - Verificar se pubkey precisa ser corrigido primeiro
   - Testar se pubkey é chave para descriptografar payload

3. **Processar textos b4 de forma diferente:**
   - Tentar diferentes combinações
   - Verificar se são partes de uma chave maior
   - Testar como seed para gerar chave

### 10.2 Prioridade Média

4. **Tentar outros métodos de esteganografia:**
   - F5
   - OutGuess
   - StegHide (já testado - não suporta PNG)

5. **Análise de frequência:**
   - Análise estatística dos padrões
   - Identificar possível cifra de substituição
   - Verificar se há padrões de criptografia conhecidos

6. **Verificar múltiplas camadas:**
   - Pode haver criptografia + compressão + esteganografia
   - Tentar aplicar transformações em sequência

---

## 📁 11. Arquivos Gerados

### 11.1 Arquivos de Dados Extraídos

- `pubkey.asc` - OpenPGP Public Key extraído (57,750 bytes)
- `payload.zlib` - Dados comprimidos extraídos (259,875 bytes)
- `pubkey_xor_*.asc` - Versões do pubkey com XOR aplicado (8 arquivos)

### 11.2 Arquivos de Análise

- `analyze_stego.py` - Script de análise esteganográfica
- `deep_analysis.py` - Script de análise profunda
- `xor_result.png` - Resultado XOR entre imagens
- `subtraction_result.png` - Resultado subtração entre imagens
- `diff_result.png` - Diferença absoluta entre imagens
- Canais RGB isolados de ambas as imagens

### 11.3 Arquivos de Metadados

- Outputs do `exiftool`
- Outputs do `binwalk`
- Outputs do `zsteg`
- Outputs do `pngcheck`

---

## 🎓 12. Conclusões

### 12.1 O Que Foi Descoberto

1. ✅ Dados ocultos confirmados em ambas as imagens
2. ✅ OpenPGP Public Key identificado
3. ✅ Zlib Compressed Data identificado
4. ✅ Textos suspeitos nos bit planes b4
5. ✅ Padrões repetitivos indicando possível criptografia

### 12.2 O Que Ainda Precisa Ser Feito

1. ❌ Descriptografar o payload.zlib
2. ❌ Corrigir/validar o pubkey.asc
3. ❌ Decodificar/utilizar os textos b4
4. ❌ Extrair a flag completa

### 12.3 Probabilidade de Sucesso

**Alta probabilidade** de que os dados necessários estejam presentes:
- Payload comprimido identificado
- Chave pública identificada
- Textos suspeitos encontrados

**Desafio principal:** Encontrar a transformação correta para:
1. Descriptografar o payload
2. Descomprimir os dados
3. Extrair a flag

---

## 📞 13. Informações Técnicas

### 13.1 Ferramentas Utilizadas

- `exiftool` - Análise de metadados
- `binwalk` - Busca por arquivos embutidos
- `zsteg` - Análise esteganográfica PNG
- `strings` - Extração de strings
- `xxd` / `hexdump` - Análise hexadecimal
- `file` - Identificação de tipos de arquivo
- `gpg` - Análise de chaves OpenPGP
- `pngcheck` - Validação PNG
- Python 3 com bibliotecas: PIL, numpy, zlib, base64, hashlib

### 13.2 Scripts Desenvolvidos

1. `analyze_stego.py` - Análise esteganográfica completa
2. `deep_analysis.py` - Análise profunda de dados descomprimidos
3. Scripts inline para testes específicos

---

## 🔍 14. Análise Detalhada dos Dados Encontrados

### 14.1 Payload.zlib - Análise Detalhada

**Características:**
- Tamanho: 259,875 bytes
- Header: `78 3F` (válido)
- Entropia: 7.77 (alta)
- Padrões: Fortemente repetitivos

**Padrões mais comuns:**
```
Byte único: 0xDB (3,666 vezes), 0x6D (3,661 vezes)
2 bytes: B6 6D (2,560 vezes)
4 bytes: 6D DB B6 6D (2,243 vezes)
```

**Interpretação:** Padrões muito repetitivos sugerem:
- XOR com chave curta (possivelmente 4 bytes)
- Ou dados parcialmente descriptografados
- Ou estrutura de dados conhecida

### 14.2 Pubkey.asc - Análise Detalhada

**Características:**
- Tamanho: 57,750 bytes
- Detectado como: OpenPGP Public Key
- Status: Corrompido/inválido
- Estrutura: Contém pacotes GPG mas com versões desconhecidas

**Tentativas de correção:**
- 7 versões com diferentes chaves XOR testadas
- Nenhuma gerou chave GPG válida
- Nenhuma string "solyd" encontrada

### 14.3 Textos b4 - Análise Detalhada

**Características combinadas:**
- Tamanho total: 74 caracteres
- Entropia: 4.61 (baixa)
- Contém caracteres especiais: `|`, `"`, `!`, `'`

**Possíveis interpretações:**
1. Chave XOR fragmentada
2. Seed para gerar chave
3. Dados codificados (Base85 customizado?)
4. Parte de uma chave maior

---

## 🎯 15. Estratégias Futuras

### 15.1 Abordagem Recomendada

1. **Focar nos padrões repetitivos:**
   - Analisar frequência detalhada
   - Tentar identificar a chave XOR
   - Verificar se padrão `6ddbb66d` é resultado conhecido

2. **Combinar todos os elementos:**
   - Payload + Pubkey + Textos b4
   - Tentar diferentes combinações
   - Verificar se há ordem específica

3. **Análise estatística:**
   - Análise de frequência de bytes
   - Identificar possível cifra
   - Verificar padrões de criptografia conhecidos

### 15.2 Hipóteses a Testar

1. Textos b4 → SHA256 → Chave XOR → Descriptografar payload
2. Padrão repetitivo → Chave XOR → Descriptografar payload
3. Pubkey corrigido → Usar para descriptografar payload
4. Múltiplas camadas: XOR → Descompressão → PGP → Flag

---

## 📝 16. Notas Finais

Este relatório documenta uma análise forense completa e sistemática das duas imagens PNG. Embora a flag completa ainda não tenha sido extraída, foram descobertos dados altamente promissores que indicam fortemente a presença de informações ocultas.

Os dados encontrados (OpenPGP key, zlib compressed data, textos suspeitos) seguem um padrão comum em desafios CTF de esteganografia avançada, onde múltiplas camadas de ocultação são utilizadas.

**Recomendação:** Continuar a investigação focando na combinação dos elementos descobertos e na análise dos padrões repetitivos encontrados no payload.

---

**Fim do Relatório**
