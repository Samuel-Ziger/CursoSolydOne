# CursoSolydOne

Repositório de materiais, scripts e anotações do **Curso Solyd** (Solyd.one) — formação em segurança ofensiva e cibersegurança. Contém exercícios de programação, shell script, pentest, CTFs e laboratórios práticos.

---

## O que é este projeto

O **CursoSolydOne** reúne o conteúdo produzido e utilizado durante o curso da Solyd: desde fundamentos de programação (C e Python) e shell script até práticas de pentest, reconhecimento web, exploração de vulnerabilidades e resolução de CTFs (Capture The Flag). Tudo destinado a **fins educacionais** e uso em ambientes autorizados.

---

## Estrutura do repositório

### Scripting e Shell
| Pasta | Descrição |
|-------|-----------|
| **Argumentos** | Scripts que usam argumentos na linha de comando |
| **Aula de introdução ao shell** | Primeiros passos em shell (atualização de sistema, pacotes, interface de rede) |
| **conditionShell** | Condicionais em shell (hosts de escopo, interface de rede) |
| **Estrutura de Repetição** | Laços de repetição em shell |
| **RepetiçãoWhileFor** | Repetição com `while` e `for` em Python |

### Programação
| Pasta | Descrição |
|-------|-----------|
| **Fundamentos.de.programação.em.C** | Exercícios iniciais em C |
| **Função** | Uso de funções em Python |
| **PythonBasic** | Conceitos básicos de Python (entrada/saída, operações) |
| **Projeto1** | Pequenos projetos Python (agenda, lista, tupla) |
| **TratamentoDeErro** | Tratamento de exceções em Python |
| **SocketEmC** | Sockets em C (cliente/servidor TCP) |
| **Socket e Client TCP** | Cliente TCP e UDP em Python |
| **ServidorTCP** | Servidor TCP em Python |

### Segurança e Pentest
| Pasta | Descrição |
|-------|-----------|
| **BruteForceDNS** | Brute force de subdomínios DNS (C e Python) |
| **baconCN** | Exemplos de SQL Injection (lab bancocn) |
| **Ferramentas** | Scripts auxiliares (ex.: login brute force, scan) |
| **GraphQl** | Consultas e brute force em GraphQL |
| **JuiceShop** | Scripts e revisões para o OWASP Juice Shop |
| **PortScan** | Port scanning (C e Python) |
| **Reconhecimento web** | Dir brute, busca de e-mails, web crawler |
| **RequestWeb** | Uso de `requests` e `urllib` em Python |
| **Ransomware** | Exemplo didático de cifragem (AES) + decrypt — **apenas educativo** |
| **SSH** | Cliente SSH em Python |
| **TemplatesNuclei** | Templates Nuclei (ex.: SQLi) |
| **Pentest Na Pratica** | Materiais e resultados de laboratório de pentest |
| **PentestChatGPT** | Scripts de pentest (subdomínios, XSS, notificações) |
| **MonitoramentoWorkflow** | Scripts de reconhecimento DNS e vulnerabilidades |
| **MultildaeSql** | Prática com múltiplos bancos SQL |

### CTFs (Capture The Flag)
| Pasta | Descrição |
|-------|-----------|
| **CTFs/HistoricoCTFsSolyd** | Histórico de CTFs da Solyd (CTF1, ctf8, CTF9) com write-ups, flags no formato `Solyd{...}` e relatórios |

### Docker e ambientes
| Pasta | Descrição |
|-------|-----------|
| **Docker/automated-pentest** | Container para pentest automatizado (Parrot OS, Nmap, Nikto, etc.) — ver `Docker/automated-pentest/README.md` |
| **Docker/DockerNmap** | Ambiente Docker com Nmap (Kali/Parrot) |
| **Docker/pentest** | Dockerfile para ambiente de pentest |
| **labs** | Configurações e perfis para laboratórios (ex.: Pentest na prática) |

### Outros
| Pasta | Descrição |
|-------|-----------|
| **srfulano** | Materiais sobre SQL e Banco CN (ex.: SqlBancoCN.md) |
| **testescriptSolyd** | Scripts de teste para labs Solyd (ex.: banco, bancoCN — SQL Injection) |

---

## Requisitos gerais

- **Shell:** Bash (Linux/WSL) ou ambiente compatível para os `.sh`
- **Python:** Python 3; em vários scripts são usados `requests`, `pyaes` (ex.: Ransomware), etc.
- **C:** Compilador GCC (ou equivalente) para os exemplos em C
- **Docker:** Para usar os containers em `Docker/` (opcional)

Para projetos específicos (ex.: bancoCN, JuiceShop), consulte o `README.md` ou comentários dentro de cada pasta.

---

## Uso rápido (exemplos)

- **Port scan (Python):**  
  `python PortScan/portscan.py <host> [portas separadas por vírgula]`
- **Dir brute (Python):**  
  `python "Reconhecimento web/dirbrute.py" <URL> <wordlist>`
- **Pentest automatizado (Docker):**  
  Ver instruções em `Docker/automated-pentest/README.md`

---

## Aviso legal

Todo o conteúdo é para **fins educacionais** e para uso em **ambientes e alvos autorizados**. O uso dessas técnicas e scripts contra sistemas sem autorização é **ilegal**. O responsável pelo uso é o usuário; os autores não se responsabilizam por mau uso.

---

## Licença e créditos

Material vinculado ao **Curso Solyd** (Solyd.one). Consulte os arquivos de licença nos subprojetos (ex.: `Docker/automated-pentest/LICENSE`) quando aplicável.
