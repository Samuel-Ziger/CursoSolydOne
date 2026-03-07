#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Análise Forense Completa de Imagens PNG
CTF - Esteganografia e Dados Ocultos
"""

from PIL import Image
import numpy as np
import binascii
import base64
import re
import sys

def extract_lsb(image, channel='all'):
    """Extrai LSB de uma imagem"""
    img_array = np.array(image)
    if len(img_array.shape) == 2:  # Grayscale
        return img_array & 1
    else:  # RGB/RGBA
        if channel == 'all':
            return img_array[:, :, :3] & 1
        elif channel == 'r':
            return img_array[:, :, 0] & 1
        elif channel == 'g':
            return img_array[:, :, 1] & 1
        elif channel == 'b':
            return img_array[:, :, 2] & 1

def lsb_to_string(lsb_array):
    """Converte array LSB em string"""
    if len(lsb_array.shape) == 3:
        flat = lsb_array.flatten()
    else:
        flat = lsb_array.flatten()
    
    bits = ''.join([str(b) for b in flat])
    bytes_data = []
    for i in range(0, len(bits), 8):
        if i + 8 <= len(bits):
            byte_val = int(bits[i:i+8], 2)
            bytes_data.append(byte_val)
    
    try:
        return bytes(bytes_data).decode('utf-8', errors='ignore')
    except:
        return bytes(bytes_data)

def extract_bit_plane(image, plane=0):
    """Extrai um bit plane específico"""
    img_array = np.array(image)
    if len(img_array.shape) == 2:
        return (img_array >> plane) & 1
    else:
        return (img_array[:, :, :3] >> plane) & 1

def xor_images(img1, img2):
    """Faz XOR entre duas imagens"""
    arr1 = np.array(img1.convert('RGB'))
    arr2 = np.array(img2.convert('RGB'))
    
    if arr1.shape != arr2.shape:
        print(f"AVISO: Imagens têm tamanhos diferentes: {arr1.shape} vs {arr2.shape}")
        min_h = min(arr1.shape[0], arr2.shape[0])
        min_w = min(arr1.shape[1], arr2.shape[1])
        arr1 = arr1[:min_h, :min_w]
        arr2 = arr2[:min_h, :min_w]
    
    return np.bitwise_xor(arr1, arr2)

def subtract_images(img1, img2):
    """Subtrai img2 de img1"""
    arr1 = np.array(img1.convert('RGB')).astype(np.int16)
    arr2 = np.array(img2.convert('RGB')).astype(np.int16)
    
    if arr1.shape != arr2.shape:
        min_h = min(arr1.shape[0], arr2.shape[0])
        min_w = min(arr1.shape[1], arr2.shape[1])
        arr1 = arr1[:min_h, :min_w]
        arr2 = arr2[:min_h, :min_w]
    
    diff = np.abs(arr1 - arr2)
    return np.clip(diff, 0, 255).astype(np.uint8)

def analyze_image(filename):
    """Análise completa de uma imagem"""
    print(f"\n{'='*60}")
    print(f"ANÁLISE: {filename}")
    print(f"{'='*60}")
    
    try:
        img = Image.open(filename)
        print(f"Dimensões: {img.size}")
        print(f"Modo: {img.mode}")
        
        # LSB Analysis
        print("\n[LSB Analysis]")
        for channel in ['r', 'g', 'b', 'all']:
            lsb = extract_lsb(img, channel)
            lsb_str = lsb_to_string(lsb)
            if isinstance(lsb_str, bytes):
                lsb_str = lsb_str.decode('utf-8', errors='ignore')
            
            # Procurar padrões
            if 'solyd' in lsb_str.lower() or 'flag' in lsb_str.lower():
                print(f"  Canal {channel}: ENCONTRADO PADRÃO SUSPEITO!")
                print(f"  Primeiros 500 chars: {lsb_str[:500]}")
            
            # Procurar base64
            base64_pattern = re.search(r'[A-Za-z0-9+/]{20,}={0,2}', lsb_str)
            if base64_pattern:
                print(f"  Canal {channel}: Possível Base64 encontrado!")
                try:
                    decoded = base64.b64decode(base64_pattern.group())
                    print(f"  Decodificado: {decoded[:100]}")
                except:
                    pass
        
        # Bit Plane Analysis
        print("\n[Bit Plane Analysis]")
        for plane in range(8):
            bp = extract_bit_plane(img, plane)
            bp_str = lsb_to_string(bp)
            if isinstance(bp_str, bytes):
                bp_str = bp_str.decode('utf-8', errors='ignore')
            
            if 'solyd' in bp_str.lower() or 'flag' in bp_str.lower():
                print(f"  Plane {plane}: ENCONTRADO PADRÃO SUSPEITO!")
                print(f"  Primeiros 500 chars: {bp_str[:500]}")
        
        # Canal isolado
        print("\n[Canal Isolado]")
        arr = np.array(img.convert('RGB'))
        for i, channel_name in enumerate(['R', 'G', 'B']):
            channel = arr[:, :, i]
            channel_img = Image.fromarray(channel)
            # Salvar canal isolado
            channel_img.save(f"{filename}_channel_{channel_name.lower()}.png")
            print(f"  Canal {channel_name} salvo em {filename}_channel_{channel_name.lower()}.png")
            
            # Extrair LSB do canal
            lsb = channel & 1
            lsb_str = lsb_to_string(lsb)
            if isinstance(lsb_str, bytes):
                lsb_str = lsb_str.decode('utf-8', errors='ignore')
            
            if 'solyd' in lsb_str.lower() or 'flag' in lsb_str.lower():
                print(f"  Canal {channel_name} LSB: ENCONTRADO PADRÃO SUSPEITO!")
                print(f"  Primeiros 500 chars: {lsb_str[:500]}")
        
    except Exception as e:
        print(f"ERRO ao analisar {filename}: {e}")
        import traceback
        traceback.print_exc()

def compare_images(img1_path, img2_path):
    """Compara duas imagens"""
    print(f"\n{'='*60}")
    print(f"COMPARAÇÃO: {img1_path} vs {img2_path}")
    print(f"{'='*60}")
    
    try:
        img1 = Image.open(img1_path)
        img2 = Image.open(img2_path)
        
        # XOR
        print("\n[XOR Analysis]")
        xor_result = xor_images(img1, img2)
        xor_img = Image.fromarray(xor_result)
        xor_img.save("xor_result.png")
        print("  Resultado XOR salvo em xor_result.png")
        
        # Extrair LSB do resultado XOR
        xor_lsb = extract_lsb(xor_img)
        xor_lsb_str = lsb_to_string(xor_lsb)
        if isinstance(xor_lsb_str, bytes):
            xor_lsb_str = xor_lsb_str.decode('utf-8', errors='ignore')
        
        if 'solyd' in xor_lsb_str.lower() or 'flag' in xor_lsb_str.lower():
            print("  XOR LSB: ENCONTRADO PADRÃO SUSPEITO!")
            print(f"  Primeiros 500 chars: {xor_lsb_str[:500]}")
        
        # Subtração
        print("\n[Subtração Analysis]")
        sub_result = subtract_images(img1, img2)
        sub_img = Image.fromarray(sub_result)
        sub_img.save("subtraction_result.png")
        print("  Resultado subtração salvo em subtraction_result.png")
        
        # Extrair LSB do resultado subtração
        sub_lsb = extract_lsb(sub_img)
        sub_lsb_str = lsb_to_string(sub_lsb)
        if isinstance(sub_lsb_str, bytes):
            sub_lsb_str = sub_lsb_str.decode('utf-8', errors='ignore')
        
        if 'solyd' in sub_lsb_str.lower() or 'flag' in sub_lsb_str.lower():
            print("  Subtração LSB: ENCONTRADO PADRÃO SUSPEITO!")
            print(f"  Primeiros 500 chars: {sub_lsb_str[:500]}")
        
        # Diferença absoluta
        print("\n[Diferença Absoluta]")
        arr1 = np.array(img1.convert('RGB')).astype(np.int16)
        arr2 = np.array(img2.convert('RGB')).astype(np.int16)
        
        if arr1.shape == arr2.shape:
            diff = np.abs(arr1 - arr2)
            diff_img = Image.fromarray(np.clip(diff, 0, 255).astype(np.uint8))
            diff_img.save("diff_result.png")
            print("  Diferença absoluta salva em diff_result.png")
            
            # Verificar se há diferenças significativas
            if np.any(diff > 0):
                print(f"  Diferenças encontradas! Max diff: {np.max(diff)}")
                # Procurar padrões nas diferenças
                diff_lsb = diff & 1
                diff_lsb_str = lsb_to_string(diff_lsb.flatten())
                if isinstance(diff_lsb_str, bytes):
                    diff_lsb_str = diff_lsb_str.decode('utf-8', errors='ignore')
                
                if 'solyd' in diff_lsb_str.lower() or 'flag' in diff_lsb_str.lower():
                    print("  Diff LSB: ENCONTRADO PADRÃO SUSPEITO!")
                    print(f"  Primeiros 500 chars: {diff_lsb_str[:500]}")
        
    except Exception as e:
        print(f"ERRO ao comparar imagens: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    img1 = "aetherpharma.png"
    img2 = "festas-ano-novo.png"
    
    analyze_image(img1)
    analyze_image(img2)
    compare_images(img1, img2)
    
    print("\n" + "="*60)
    print("ANÁLISE COMPLETA FINALIZADA")
    print("="*60)
