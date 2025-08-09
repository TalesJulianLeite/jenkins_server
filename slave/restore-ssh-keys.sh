#!/bin/bash

# Restaura chaves SSH se existirem no volume persistente
if [ -f /ssh-keys-persistent/ssh_host_rsa_key ]; then
    cp -f /ssh-keys-persistent/ssh_host_* /etc/ssh/keys/
    chmod 600 /etc/ssh/keys/*_key
    chmod 644 /etc/ssh/keys/*.pub
    chown root:root /etc/ssh/keys/*
fi

# Garante que o diretório .ssh do jenkins existe
mkdir -p /home/jenkins/.ssh
chown jenkins:jenkins /home/jenkins/.ssh
chmod 700 /home/jenkins/.ssh