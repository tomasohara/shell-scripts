from bs4 import BeautifulSoup

with open("./kcov-output/hello-world-basic/index.html", "r") as file:

    soup = BeautifulSoup(file, "html.parser")
    bats_link = soup.select("center")
    print (bats_link)

