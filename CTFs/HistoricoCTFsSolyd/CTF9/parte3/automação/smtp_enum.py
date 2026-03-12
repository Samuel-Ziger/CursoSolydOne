#!/usr/bin/env python3
"""Enumera SMTP na porta 25 - comandos e possíveis flags. Alvo: 98.92.111.173"""
import socket
import sys

TARGET = "98.92.111.173"
PORT = 25
TIMEOUT = 10

def recv_until(s, end=b"\n"):
    buf = b""
    while end not in buf:
        try:
            chunk = s.recv(1)
            if not chunk:
                break
            buf += chunk
        except socket.timeout:
            break
    return buf.decode("utf-8", errors="replace")

def smtp_cmd(s, cmd):
    s.sendall((cmd + "\r\n").encode())
    return recv_until(s)

def main():
    out = []
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(TIMEOUT)
        s.connect((TARGET, PORT))
        banner = recv_until(s)
        out.append(f"[BANNER]\n{banner}")
        for cmd in ["EHLO lb-test", "HELP", "VRFY root", "VRFY lb-test", "EXPN root", "EXPN lb-test", "MAIL FROM:<>", "RCPT TO:<lb-test@lb-test>", "NOOP", "RSET"]:
            try:
                r = smtp_cmd(s, cmd)
                out.append(f"[{cmd}]\n{r}")
                if "flag" in r.lower() or "solyd" in r.lower() or "{" in r:
                    out.append(f"*** POSSIVEL FLAG em resposta a {cmd} ***")
            except Exception as e:
                out.append(f"[{cmd}] ERRO: {e}")
        s.close()
    except Exception as e:
        out.append(f"ERRO CONEXAO: {e}")
    result = "\n".join(out)
    print(result)
    with open("/home/kali/Desktop/CursoSolydOne/CTFs/HistoricoCTFsSolyd/CTF9/parte3/automação/smtp_enum_result.txt", "w") as f:
        f.write(result)
    return result

if __name__ == "__main__":
    main()
