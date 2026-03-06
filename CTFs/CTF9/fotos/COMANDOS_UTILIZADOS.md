# Comandos Utilizados na Análise Forense

## 📋 Índice
1. [Análise Básica](#análise-básica)
2. [Extração de Dados](#extração-de-dados)
3. [Análise Esteganográfica](#análise-esteganográfica)
4. [Análise de Criptografia](#análise-de-criptografia)
5. [Scripts Python](#scripts-python)

---

## 🔍 Análise Básica

### Identificação de Arquivos
```bash
file aetherpharma.png festas-ano-novo.png
```

### Metadados EXIF
```bash
exiftool -a -u -g1 aetherpharma.png festas-ano-novo.png
```

### Validação PNG
```bash
pngcheck -v aetherpharma.png festas-ano-novo.png
```

### Busca por Arquivos Embutidos
```bash
binwalk aetherpharma.png festas-ano-novo.png
```

### Extração de Strings
```bash
strings -a -n 4 aetherpharma.png | head -50
strings -a -n 4 festas-ano-novo.png | head -50
strings -a -n 10 aetherpharma.png festas-ano-novo.png | grep -iE "(solyd|flag|ctf)"
```

---

## 📦 Extração de Dados

### Extrair OpenPGP Public Key
```bash
zsteg -E b2,b,lsb aetherpharma.png > pubkey.asc
gpg --list-packets pubkey.asc
gpg --import pubkey.asc
```

### Extrair Zlib Compressed Data
```bash
zsteg -E b3,rgb,msb festas-ano-novo.png > payload.zlib
file payload.zlib
xxd payload.zlib | head -20
```

### Análise com zsteg Completa
```bash
zsteg aetherpharma.png festas-ano-novo.png
```

---

## 🎨 Análise Esteganográfica

### Análise Completa com zsteg
```bash
zsteg aetherpharma.png festas-ano-novo.png
```

### Extrair Dados de Bit Planes Específicos
```bash
zsteg -E b4,rgb,lsb aetherpharma.png > aether_b4_rgb_lsb.dat
zsteg -E b4,rgb,lsb festas-ano-novo.png > festas_b4_rgb_lsb.dat
```

### Verificar Esteganografia com StegHide
```bash
steghide info aetherpharma.png
steghide info festas-ano-novo.png
```

---

## 🔐 Análise de Criptografia

### Tentar Descomprimir Zlib
```python
import zlib
with open('payload.zlib', 'rb') as f:
    data = f.read()
decompressed = zlib.decompress(data)
```

### Tentar Raw Deflate
```python
decompressed = zlib.decompress(data, -15)
```

### Procurar Headers Zlib em Outros Offsets
```python
for i in range(len(data)-1):
    if data[i] == 0x78:
        if (data[i]*256 + data[i+1]) % 31 == 0:
            print("Possível zlib em offset:", i)
            try:
                decompressed = zlib.decompress(data[i:])
                print("✅ Descomprimido!")
            except:
                pass
```

### Aplicar XOR Global
```python
xor_key = 0xA3  # Exemplo
xored_data = bytearray(data)
for i in range(len(xored_data)):
    xored_data[i] ^= xor_key
decompressed = zlib.decompress(bytes(xored_data))
```

---

## 🐍 Scripts Python

### Script de Análise Esteganográfica
```bash
python3 analyze_stego.py
```

### Script de Análise Profunda
```bash
python3 deep_analysis.py
```

### Análise de Entropia
```python
import math
from collections import Counter

def calculate_entropy(data):
    entropy = 0
    for count in Counter(data).values():
        p_x = count / len(data)
        if p_x > 0:
            entropy += -p_x * math.log2(p_x)
    return entropy
```

### Extrair LSB de Imagem
```python
from PIL import Image
import numpy as np

img = Image.open('aetherpharma.png')
arr = np.array(img.convert('RGB'))
lsb = arr & 1
```

### XOR entre Imagens
```python
img1 = Image.open('aetherpharma.png')
img2 = Image.open('festas-ano-novo.png')
arr1 = np.array(img1.convert('RGB'))
arr2 = np.array(img2.convert('RGB'))
xor_result = np.bitwise_xor(arr1, arr2)
```

---

## 🔧 Comandos Úteis Adicionais

### Verificar Hash MD5
```bash
md5sum aetherpharma.png festas-ano-novo.png
```

### Análise Hexadecimal
```bash
xxd aetherpharma.png | head -50
hexdump -C aetherpharma.png | tail -20
```

### Buscar Padrões Hex Específicos
```bash
xxd payload.zlib | grep "78"
```

### Verificar Tamanho de Arquivos
```bash
ls -lh *.png *.asc *.zlib
```

### Procurar Flag em Todos os Arquivos
```bash
grep -r "solyd" . 2>/dev/null
strings -a *.asc *.zlib | grep -i solyd
```

---

## 📝 Notas Importantes

1. **zsteg** é a ferramenta principal para análise esteganográfica em PNG
2. **zlib.decompress()** com `-15` força raw deflate (sem header)
3. Headers zlib válidos devem satisfazer: `(CMF*256 + FLG) % 31 == 0`
4. Padrões repetitivos podem indicar XOR com chave curta
5. Textos nos bit planes b4 podem ser chaves ou seeds

---

**Última atualização:** 27 de Fevereiro de 2026
