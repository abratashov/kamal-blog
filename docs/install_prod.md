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

https://dash.cloudflare.com/

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
mkdir ~/.ssh
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
```

### Setup deployer access
```sh
adduser deployer
usermod -aG sudo deployer
exit
ssh deployer@1.2.3.4
mkdir ~/.ssh
touch ~/.ssh/authorized_keys
exit
local$ cat ~/.ssh/id_ed25519.pub | ssh deployer@1.2.3.4 'cat >> ~/.ssh/authorized_keys'
```

### Install extra tools
```sh
# Docker
sudo apt install -y docker.io curl git
sudo docker --version
sudo usermod -aG docker $USER

# Letsencrypt
sudo mkdir -p /letsencrypt && sudo touch /letsencrypt/acme.json && sudo chmod 600 /letsencrypt/acme.json

# Text editor
sudo apt install micro

sudo reboot
```

## [Setup application](https://kamal-deploy.org/)

### Add env config files

Set all needed credentials that are used in the `config/initializers/environment_loader.rb`:

```sh
# Create and fill ENV file for config/deploy.demo.yml
cp .default.env.demo .env.demo
```

### Setup app

```sh
# Build server
gem install kamal
kamal setup -d demo

# Change DB password in case of sensitive data
# ...
```

```sh
# Add full read/write access for shared folders
sudo chmod 777 -R /data/storage
sudo chmod 777 -R /data/uploads
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
# <put here content of bin/server/firewall.sh>

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

### Audit packages signature with Debsums

```sh
sudo apt update && sudo apt install debsums
sudo debsums | grep -vi "OK"
```

### Audit with Lynis

```sh
sudo apt update && sudo apt install lynis
sudo lynis audit system --quick
sudo lynis audit system
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
local$ kamal app logs -g b7b72d8b-d2c6-4536-800e-0bf5420d6c95
local$ kamal traefik logs
```

## Extra docs

### 3rd party services

TODO: Server up monitoring, AWS, etc.

### System architecture

TODO:
* feature1/module1/services1
* ...
* featureN/moduleN/servicesN

### Calendar events of server maintenance

TODO:
* clean up docker images, logs, etc.
* updates/upgrades: `sudo apt-get upgrade -y`
* check backups: DB & app data restoring, AWS, etc.
* security audit
* testing
* etc.

### Useful commands

TODO:
* server access, etc.
* server access, etc.

#### Kamal & Docker
```sh
# Push updates
local$ kamal deploy -d demo

# Cleanup docker in case of errors of lack of space on server
docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)
docker system prune -a

# Clean up space of local builds in case of lack of space on your machine
local$ kamal build remove -d demo
```

```sh
# Push updated env vars
kamal app stop -d demo
kamal env push -d demo
kamal app start -d demo
kamal app boot -d demo
kamal traefik reboot -d demo

# Create new session
kamal app exec -i --reuse bash -d demo
kamal app exec -i 'bin/rails c' -d demo

# Attach to exists container & hot reload Ruby files without deploy
docker ps -a
docker exec -it --user root 49270eee5086 bash
apt-get update
apt-get install micro
micro path_to_editable/file.rb
exit
docker restart 49270eee5086

docker exec -it 49270eee5086 bin/rails c
```
