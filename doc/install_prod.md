# Install production server

1. Create VPS instance: hetzner.com / fotbo.com / etc.
2. Pre-setup server: OS updates, user credentials, extra tools, etc.
3. Setup application: Kamal, backups, files storage, etc.
4. Post-setup server: iptables, fail2ban, etc
5. Security audit: ports, cron, reset, health services, etc.
6. Check features: manual, capybara, etc.
7. Extra docs: envs, system architecture, etc.

## VPS

Create VPS instance: hetzner.com / fotbo.com / etc.

### Setup CloudFlare

* Add DNS record for `myapp.domain.org`:
```
Type    Name          IPv4 address    Proxy status    TTL
A       domain.org    1.2.3.4         No              Auto
A       myapp         1.2.3.4         Yes             Auto
```
* SSL/TLS encryption mode: Full
* SSL/TLS Recommender: true

### Add Docker image

Create an image in one of these services:
https://hub.docker.com/
https://github.com/usernamev?tab=packages
https://gitlab.com/-/user_settings/personal_access_tokens
* Token name: gitlab_docker_my_app_demo
* Add permissions: read_registry, write_registry

## Pre-setup server

### Setup root access
```sh
ssh root@1.2.3.4
touch ~/.ssh/authorized_keys

local$ cat ~/.ssh/id_ed25519.pub | ssh root@1.2.3.4 'cat >> ~/.ssh/authorized_keys'
```

### Upgrade system
```sh
df -h /
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade
sudo apt-get autoclean
reboot
```

### Setup deployer access
```sh
adduser deployer
usermod -aG sudo deployer
exit
ssh deployer@1.2.3.4
mkdir ~/.ssh
touch ~/.ssh/authorized_keys
local$ cat ~/.ssh/id_ed25519.pub | ssh deployer@1.2.3.4 'cat >> ~/.ssh/authorized_keys'
```

### Install extra tools
```sh
# Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
docker --version
sudo usermod -aG docker $USER
newgrp docker

# Letsencrypt
sudo mkdir -p /letsencrypt && sudo touch /letsencrypt/acme.json && sudo chmod 600 /letsencrypt/acme.json

# Text editor
sudo apt install micro

sudo reboot
```

## [Setup application](https://kamal-deploy.org/)

### Add env config files

Set all needed credentials that are used in the `config/initializers/environment_loader.rb`:

<details>
  <summary>.env.demo</summary>

  ```sh
  #.env.demo for config/deploy.demo.yml

  ################################################# Docker
  DOCKER_SERVER=registry.gitlab.com
  DOCKER_USERNAME=username
  DOCKER_REGISTRY_PASSWORD=glpat-token
  DOCKER_IMAGE=username/kamal-blog/kamal-blog-demo
  DOCKER_CONTAINER=kamal-blog-demo

  ################################################# Server
  SERVER_USER=deployer
  SERVER_IP=1.2.3.4
  SERVER_HOSTNAME=myapp.domain.org
  SERVER_SSL_EMAIL=myapp@domain.org

  ################################################# DB Postgres
  DB_NAME=myapp_production
  DB_USER=deployer
  DB_PASSWORD=pgpass
  DB_HOST=1.2.3.4

  ################################################# DB Redis
  REDIS_PASSWORD=redispass
  REDIS_URL=redis://:redispass@172.17.0.1:6379/0

  ################################################# Email settings
  EMAIL_USER=myapp@domain.org
  EMAIL_PASSWORD='emailpass'
  EMAIL_ADDRESS=mail.domain.org
  EMAIL_PORT=587
  EMAIL_DOMAIN=domain.org
  EMAIL_AUTOTLS=true
  EMAIL_AUTH=login

  ################################################# OTHER
  RAILS_MASTER_KEY=<content of config/master.key>
  ```
</details>

```sh
# Build server
gem install kamal
kamal setup -d demo

# Update server
kamal deploy -d demo
```

```sh
# Add full read/write access for shared folders
sudo chmod 666 -R /data/storage
sudo chmod 666 -R /data/uploads
```

## Post-setup server

### Protect access by fail2ban

```sh
sudo apt install fail2ban -y
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo service fail2ban restart
```

### Close ports by iptables

```sh
sudo touch /data/firewall.sh && sudo chmod 777 /data/firewall.sh
micro /data/firewall.sh
```
<details>
  <summary>firewall.sh</summary>

  ```sh
  #!/usr/bin/env sh

  # Wait until Docker applies its own rules
  while ! sudo iptables -n --list DOCKER >/dev/null 2>&1
  do
    sleep 1;
  done

  # Close 5432 for all
  if [ -z "$(sudo iptables -S | grep -- '-A DOCKER -p tcp -m tcp --dport 5432 -j DROP')" ]; then
    sudo iptables -I DOCKER -s 0.0.0.0/0 -p tcp --dport 5432 -j DROP
  fi

  # Open 5432 for Docker
  if [ -z "$(sudo iptables -S | grep -- '-A DOCKER -s 172.16.0.0/12 -p tcp -m tcp --dport 5432 -j ACCEPT')" ]; then
    sudo iptables -I DOCKER -s 172.16.0.0/12 -p tcp --dport 5432 -j ACCEPT
  fi

  # Close 6379 for all
  if [ -z "$(sudo iptables -S | grep -- '-A DOCKER -p tcp -m tcp --dport 6379 -j DROP')" ]; then
    sudo iptables -I DOCKER -s 0.0.0.0/0 -p tcp --dport 6379 -j DROP
  fi

  # Open 6379 for Docker
  if [ -z "$(sudo iptables -S | grep -- '-A DOCKER -s 172.16.0.0/12 -p tcp -m tcp --dport 6379 -j ACCEPT')" ]; then
    sudo iptables -I DOCKER -s 172.16.0.0/12 -p tcp --dport 6379 -j ACCEPT
  fi
  ```
</details>

```sh
# Update Cron to load firewall script after reboot
sudo crontab -e
# Add this line
@reboot /bin/bash -c "/data/firewall.sh"

sudo reboot

# Check applied rules
sudo iptables -L --line-number
```

## [Security audit](https://www.hostduplex.com/blog/best-malware-scanners-for-linux/)

### Audit with Chkrootkit

```sh
sudo apt install chkrootkit
sudo chkrootkit
```

### Audit with Rkhunter

```sh
sudo apt install rkhunter
sudo rkhunter --update
sudo rkhunter --check --skip-keypress
```

### Audit with Lynis

```sh
sudo apt update && sudo apt install Lynis
sudo lynis audit system
sudo lynis audit system --quick
```

### Audit packages signature with Debsums

```sh
sudo apt update && sudo apt install debsums
sudo debsums | grep -vi "OK"
```

### Audit files with ClamAV

```sh
sudo apt install clamav
sudo systemctl stop clamav-freshclam
sudo freshclam
sudo clamscan -ir / | grep -viE 'OK|Symbolic link|Empty file|Excluded'
```

### Audit ports with Nmap/Telnet

```sh
nmap -Pn -p- 1.2.3.4

telnet 1.2.3.4 6379
telnet 1.2.3.4 5432
```
## Check features

### Testing

* rspec tests
* capybara scenarios
* manual testing

### Explore errors in logs

```sh
# Check logs in case of errors by Request-ID from Chrome DevTools
kamal app logs -g b7b72d8b-d2c6-4536-800e-0bf5420d6c95

kamal traefik logs
```

## Extra docs

### 3rd party services

Server up monitoring, AWS, etc.

### System architecture

* feature1/module1/services1
* ...
* featureN/moduleN/servicesN

### Calendar events of server maintenance
* clean up docker images, logs, etc.
* updates/upgrades: `sudo apt-get upgrade -y`
* check backups: DB & app data restoring, AWS, etc.
* security audit
* testing
* etc.

### Useful commands

* server access, etc.
