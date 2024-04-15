#!/bin/bash

# Atualização do sistema
apt update && apt upgrade -y

# Instalação de dependências
apt install -y apache2 mariadb-server php php-mbstring php-gd php-xml php-fpm php-mysqlnd nginx certbot

# Configuração do servidor Apache2
a2enmod rewrite headers proxy_html proxy_wstunnel
a2dismod ssl
systemctl restart apache2

# Configuração do servidor MariaDB
mysql_secure_installation

# Criação de banco de dados e usuário para OCS Inventory
mysql -u root -p << EOF
CREATE DATABASE ocsinventory;
GRANT ALL PRIVILEGES ON ocsinventory.* TO 'ocsinventory'@'localhost' IDENTIFIED BY 'zebr@tlp44';
FLUSH PRIVILEGES;
EOF

# Download dos pacotes OCS Inventory NG
wget -O - https://www.ocsinventory-ng.org/packages/debian/pool/main/o/ocsinventory-server/ocsinventory-server_2.9.2.tar.gz | tar -xzvf -
cd ocsinventory-server-2.9.2

# Instalação do OCS Inventory NG
./install.php --lang pt_BR --db_type mysql --db_host localhost --db_name ocsinventory --db_user ocsinventory --db_pass zebr@tlp44 --ocs_server_url https://10.27.200.211/ocsinventory/ --ocs_ssl false --apache_install true --nginx_install false

# Configuração do firewall
ufw allow 80
ufw allow 443
ufw enable

# Download e instalação do agente OCS Inventory NG
wget https://www.ocsinventory-ng.org/packages/debian/pool/main/o/ocsinventory-agent/ocsinventory-agent_2.9.2.amd64.deb
dpkg -i ocsinventory-agent_2.9.2.amd64.deb

# Geração de certificado SSL com o Certbot
certbot certonly --apache-live --agree-tos --email cgti.jua@ifba.edu.br

# Configuração do Nginx para HTTPS
cp /etc/letsencrypt/live/10.27.200.211/fullchain.pem /etc/nginx/ssl/ocsinventory.pem
cp /etc/letsencrypt/live/10.27.200.211/privkey.pem /etc/nginx/ssl/ocsinventory.key

nano /etc/nginx/sites-available/ocsinventory.conf

# Adicione o seguinte conteúdo ao arquivo:

server {
    listen 443 ssl;
    server_name 10.27.200.211;

    ssl_certificate /etc/nginx/ssl/ocsinventory.pem;
    ssl_certificate_key /etc/nginx/ssl/ocsinventory.key;

    location / {
        proxy_pass http://localhost:80/ocsinventory/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}

# Ative o site OCS Inventory e reinicie o Nginx
ln -s /etc/nginx/sites-available/ocsinventory.conf /etc/nginx/sites-enabled/ocsinventory.conf
systemctl restart nginx

# Finalização
echo "Instalação do OCS Inventory NG finalizada!"
echo "Acesse https://S10.27.200.211/ocsinventory/ para fazer login."
