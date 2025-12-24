import requests

cabecalho = {"User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101 Firefox/78.0",
             "Cookie": "__cfduid=dc6f5dae78cd2080e6d2d50e6131afce81614267753; cf_clearance=e5dd020d403f6a9a1a0b50eddc860a4e2b11a9e2-1614267753-0-150"}

dados = {"user": "admin", "password": "senhafoda"}

resposta = requests.post("http://www.bancocn.com/admin/index.php", headers=cabecalho, data=dados)
html = resposta.text
print(html)