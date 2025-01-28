#!/bin/bash
sudo apt update
sudo apt install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>This message from : $(hostname -i)</h1>" > /var/www/html/index.html
