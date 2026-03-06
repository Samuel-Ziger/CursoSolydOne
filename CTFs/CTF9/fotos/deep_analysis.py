#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Análise Profunda - Descompressão de dados PNG e análise de pixels
"""

import zlib
import struct
from PIL import Image
import numpy as np

def extract_idat_data(filename):
    """Extrai e descomprime todos os dados IDAT"""
    with open(filename, 'rb') as f:
        data = f.read()
    
    # Verificar header PNG
    if data[:8] != b'\x89PNG\r\n\x1a\n':
        print('ERRO: Não é um PNG válido!')
        return None
    
    offset = 8
    idat_chunks = []
    
    while offset < len(data):
        if offset + 8 > len(data):
            break
        
        chunk_len = struct.unpack('>I', data[offset:offset+4])[0]
        chunk_type = data[offset+4:offset+8]
        
        if chunk_type == b'IDAT':
            chunk_data = data[offset+8:offset+8+chunk_len]
            idat_chunks.append(chunk_data)
        
        offset += 8 + chunk_len + 4
        
        if chunk_type == b'IEND':
            break
    
    # Concatenar todos os chunks IDAT
    all_idat = b''.join(idat_chunks)
    
    # Descomprimir
    try:
        decompressed = zlib.decompress(all_idat)
        return decompressed
    except Exception as e:
        print(f'ERRO ao descomprimir: {e}')
        return None

def analyze_decompressed_data(decompressed, width, height):
    """Analisa os dados descomprimidos"""
    print(f'\n=== Análise dos Dados Descomprimidos ===')
    print(f'Tamanho descomprimido: {len(decompressed)} bytes')
    print(f'Esperado (com filtros): {width * height * 3 + height} bytes')
    
    # Os dados PNG descomprimidos têm um byte de filtro por linha
    # Formato: [filtro][dados da linha] para cada linha
    
    # Extrair apenas os dados de pixel (ignorar bytes de filtro)
    pixel_data = []
    for y in range(height):
        line_start = y * (width * 3 + 1)
        if line_start + 1 < len(decompressed):
            filter_byte = decompressed[line_start]
            line_data = decompressed[line_start + 1:line_start + 1 + width * 3]
            pixel_data.extend(line_data)
    
    pixel_array = np.array(pixel_data, dtype=np.uint8)
    
    # Análise LSB dos dados brutos
    print('\n[LSB Analysis - Dados Descomprimidos]')
    lsb_bits = pixel_array & 1
    bits_str = ''.join([str(b) for b in lsb_bits])
    
    # Converter para bytes
    bytes_data = []
    for i in range(0, len(bits_str), 8):
        if i + 8 <= len(bits_str):
            byte_val = int(bits_str[i:i+8], 2)
            bytes_data.append(byte_val)
    
    lsb_bytes = bytes(bytes_data)
    lsb_str = lsb_bytes.decode('utf-8', errors='ignore')
    
    # Procurar padrões
    if 'solyd' in lsb_str.lower():
        idx = lsb_str.lower().find('solyd')
        print('🚨 ENCONTRADO "solyd" no LSB dos dados descomprimidos!')
        print(f'Contexto: {lsb_str[max(0, idx-50):idx+200]}')
        return lsb_str[max(0, idx-50):idx+200]
    
    if 'flag' in lsb_str.lower():
        idx = lsb_str.lower().find('flag')
        print('🚨 ENCONTRADO "flag" no LSB dos dados descomprimidos!')
        print(f'Contexto: {lsb_str[max(0, idx-50):idx+200]}')
        return lsb_str[max(0, idx-50):idx+200]
    
    # Verificar outros bit planes
    for plane in range(1, 8):
        plane_bits = (pixel_array >> plane) & 1
        bits_str = ''.join([str(b) for b in plane_bits])
        bytes_data = []
        for i in range(0, len(bits_str), 8):
            if i + 8 <= len(bits_str):
                byte_val = int(bits_str[i:i+8], 2)
                bytes_data.append(byte_val)
        plane_bytes = bytes(bytes_data)
        plane_str = plane_bytes.decode('utf-8', errors='ignore')
        
        if 'solyd' in plane_str.lower() or 'flag' in plane_str.lower():
            print(f'🚨 ENCONTRADO padrão no bit plane {plane}!')
            if 'solyd' in plane_str.lower():
                idx = plane_str.lower().find('solyd')
                print(f'Contexto: {plane_str[max(0, idx-50):idx+200]}')
                return plane_str[max(0, idx-50):idx+200]
    
    return None

def analyze_pixel_differences(img1_path, img2_path):
    """Analisa diferenças pixel a pixel"""
    print(f'\n=== Análise de Diferenças Pixel a Pixel ===')
    
    img1 = Image.open(img1_path)
    img2 = Image.open(img2_path)
    
    arr1 = np.array(img1.convert('RGB'))
    arr2 = np.array(img2.convert('RGB'))
    
    if arr1.shape != arr2.shape:
        print('AVISO: Imagens têm tamanhos diferentes!')
        return
    
    # Diferença absoluta
    diff = np.abs(arr1.astype(np.int16) - arr2.astype(np.int16))
    
    # Extrair LSB das diferenças
    diff_lsb = diff & 1
    bits_str = ''.join([str(b) for b in diff_lsb.flatten()])
    
    bytes_data = []
    for i in range(0, len(bits_str), 8):
        if i + 8 <= len(bits_str):
            byte_val = int(bits_str[i:i+8], 2)
            bytes_data.append(byte_val)
    
    diff_bytes = bytes(bytes_data)
    diff_str = diff_bytes.decode('utf-8', errors='ignore')
    
    if 'solyd' in diff_str.lower():
        idx = diff_str.lower().find('solyd')
        print('🚨 ENCONTRADO "solyd" no LSB das diferenças!')
        print(f'Contexto: {diff_str[max(0, idx-50):idx+200]}')
        return diff_str[max(0, idx-50):idx+200]
    
    # Verificar valores das diferenças diretamente
    diff_values = diff.flatten()
    diff_bytes = diff_values.astype(np.uint8).tobytes()
    diff_str = diff_bytes.decode('utf-8', errors='ignore')
    
    if 'solyd' in diff_str.lower():
        idx = diff_str.lower().find('solyd')
        print('🚨 ENCONTRADO "solyd" nos valores das diferenças!')
        print(f'Contexto: {diff_str[max(0, idx-50):idx+200]}')
        return diff_str[max(0, idx-50):idx+200]
    
    return None

if __name__ == "__main__":
    # Analisar primeira imagem
    print("="*60)
    print("ANÁLISE PROFUNDA: aetherpharma.png")
    print("="*60)
    
    decompressed1 = extract_idat_data('aetherpharma.png')
    if decompressed1:
        result1 = analyze_decompressed_data(decompressed1, 700, 330)
        if result1:
            print(f'\n🎯 FLAG ENCONTRADA: {result1}')
    
    # Analisar segunda imagem
    print("\n" + "="*60)
    print("ANÁLISE PROFUNDA: festas-ano-novo.png")
    print("="*60)
    
    decompressed2 = extract_idat_data('festas-ano-novo.png')
    if decompressed2:
        result2 = analyze_decompressed_data(decompressed2, 700, 330)
        if result2:
            print(f'\n🎯 FLAG ENCONTRADA: {result2}')
    
    # Comparar diferenças
    print("\n" + "="*60)
    print("ANÁLISE DE DIFERENÇAS")
    print("="*60)
    
    result_diff = analyze_pixel_differences('aetherpharma.png', 'festas-ano-novo.png')
    if result_diff:
        print(f'\n🎯 FLAG ENCONTRADA: {result_diff}')
