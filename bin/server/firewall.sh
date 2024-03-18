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
