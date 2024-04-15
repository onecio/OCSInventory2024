#!/bin/bash

# Atualizar o sistema
sudo apt update && sudo apt upgrade -y

# Instalar o Apache e o PHP
sudo apt install apache2 php libapache2-mod-php php-curl php-mysql php-xml php-mbstring php-gd php-pear php-bcmath -y

# Instalar o MySQL e configurá-lo
sudo apt install mysql-server mysql-client -y

# Definir a senha do MySQL como 'zebr@tlp44'
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'zebr@tlp44'; FLUSH PRIVILEGES;"

# Criar o banco de dados para o OCS Inventory NG
sudo mysql -e "CREATE DATABASE ocsweb CHARACTER SET utf8 COLLATE utf8_general_ci;"

# Criar o usuário do banco de dados
sudo mysql -e "GRANT ALL ON ocsweb.* TO 'ocs'@'localhost' IDENTIFIED BY 'zebr@tlp44'; FLUSH PRIVILEGES;"

# Reiniciar o serviço MySQL
sudo systemctl restart mysql

# Baixar e instalar o OCS Inventory NG
wget https://github.com/OCSInventory-NG/OCSInventory-Server/releases/download/2.9/OCSNG_UNIX_SERVER_2.9.tar.gz
tar -xzf OCSNG_UNIX_SERVER_2.9.tar.gz
cd OCSNG_UNIX_SERVER_2.9
sudo sh setup.sh

# Configurar o OCS Inventory NG
sudo nano /etc/apache2/conf-available/ocsinventory-reports.conf

# Adicione as seguintes linhas:
# PerlSetEnv OCS_OPT_LOG_FILE /var/log/ocsinventory-server/debug.log
# PerlSetEnv OCS_OPT_SSL_PATH /etc/ssl/

# Salve e feche o arquivo

# Habilitar o módulo CGI e reiniciar o Apache
sudo a2enconf ocsinventory-reports
sudo a2enmod cgi
sudo systemctl restart apache2

# Configurar o IP do servidor no OCS Inventory NG
sudo sed -i 's/^server_ip=.*/server_ip=10.27.200.211/' /etc/ocsinventory-server/ocsinventory-server.conf

# Reiniciar o serviço OCS Inventory NG
sudo systemctl restart ocsinventory-server

echo "Instalação concluída. Acesse o OCS Inventory NG em http://10.27.200.211/ocsreports"
