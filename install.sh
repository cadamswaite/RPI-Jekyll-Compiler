#!/bin/bash

echo "Beginning install script.."

echo "Performing updates"
apt-get update && apt-get upgrade -y

#SSH security from https://www.raspberrypi.org/documentation/configuration/security.md

echo "Installing ssh server"
apt-get -qq install openssh-server -y
service ssh start
echo "Started ssh server"

echo "Generating ssh key"
# Make directory accessible to pi for now, so it can generate keys in that folder.
sudo -u pi -g pi -- mkdir /home/pi/.ssh/
sudo -u pi -g pi -- ssh-keygen -t rsa -f /home/pi/.ssh/id_rsa -q -P ""
mv /home/pi/.ssh/id_rsa.pub /home/pi/.ssh/authorized_keys
echo -e "Default \e[31mSSH key generated. Please copy id_rsa to PC now and press enter to continue\e[m"
read enter
rm /home/pi/.ssh/id_rsa
chmod 644 /home/pi/.ssh/authorized_keys
chmod 700 /home/pi/.ssh/


echo "Securing ssh"
sed -i 's/ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication .*/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/UsePAM .*/UsePAM no/g' /etc/ssh/sshd_config
service ssh reload

echo "Installing ufw"
apt-get -qq install ufw -y
ufw enable
ufw allow ssh
ufw limit ssh/tcp

echo "Installing fail2ban"
apt-get -qq install fail2ban -y
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
# Ban IPs forever if they fail 3 times. To unblock, use:
# fail2ban-client set sshd unbanip <IP>
# Check blocked IPs using fail2ban-client status sshd
sed -i 's/^\[sshd\]/[sshd]\nenabled = true\nfilter = sshd\nbanaction = iptables-multiport\nbantime = -1\nmaxretry = 3\n/g' /etc/fail2ban/jail.local

# Block any ips that fail to provide a certificate 3 times.
sed -i 's|failregex = |failregex = ^Connection \(closed\|reset\) by authenticating user pi <HOST> port \\d+ \\\[preauth\\\]$\n            |g' /etc/fail2ban/filter.d/sshd.conf  

systemctl restart fail2ban
echo "Fail2ban set up"

# Download bottle for creating webhooks
echo "Downloading Bottle"
wget https://bottlepy.org/bottle.py

# Download python script for creating webpages
ufw allow 80
ip addr show
wget https://raw.githubusercontent.com/cadamswaite/RPI-Jekyll-Compiler/master/webhook.py

#Install Jekyll
echo "Installing Jekyll"
apt-get install ruby-full build-essential -y
echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
gem install jekyll bundler
echo "Jekyll and bundler installed."

python ./webhook.py


echo "Install complete!"
