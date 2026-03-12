#!/usr/bin/env python3
"""Explora porta 58000 - eco/unknown. Alvo: 98.92.111.173"""
import socket
import sys

TARGET = "98.92.111.173"
PORT = 58000
TIMEOUT = 5

def try_send(msg):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(TIMEOUT)
        s.connect((TARGET, PORT))
        s.sendall((msg + "\n").encode())
        data = b""
        try:
            while True:
                chunk = s.recv(4096)
                if not chunk:
                    break
                data += chunk
                if len(chunk) < 4096:
                    break
        except socket.timeout:
            pass
        s.close()
        return data.decode("utf-8", errors="replace").strip()
    except Exception as e:
        return f"ERRO: {e}"

def main():
    msgs = ["helo", "hello", "flag", "FLAG", "flag\n", "get", "GET", "help", "HELP", "ls", "id", "whoami", "cat flag", "solyd", "lb-test", ""]
    out = []
    for m in msgs:
        r = try_send(m)
        out.append(f"[SEND: {repr(m)}] -> {repr(r)}")
        if r and ("flag" in r.lower() or "solyd" in r.lower() or "{" in r):
            out.append("*** POSSIVEL FLAG ***")
    result = "\n".join(out)
    print(result)
    with open("/home/kali/Desktop/CursoSolydOne/CTFs/HistoricoCTFsSolyd/CTF9/parte3/automação/porta_58000_result.txt", "w") as f:
        f.write(result)
    return result

if __name__ == "__main__":
    main()
