Pré-requisitos:

- Docker instalado;

Instruções para execução do projeto:

1. Realize o download do código fonte ou realize o clone do mesmo.
2. Entre no diretório do projeto via prompt de comando ou abra a pasta "Jenkins" como um projeto ou pasta em sua IDE de preferência.
3. Crie um rede docker denominada "jenkins" com o comando abaixo:
    ```docker create network jenkins```
4. Estando no diretório denominado "Jenkins", realize o comando abaixo via prompt:
    ```docker-compose up -d```
Pronto!! Seu Jenkins clusterizado master e os slaves já estará em execução.

4. Acesse a URL www.localhost:8080/ do seu navegador de preferência.

(Imagem da tela de login)

5. Cadastre um novo usuário administrador e senha.
