#!/bin/bash
set -e

# Restaura chaves SSH se existirem no volume persistente
if [ -f /ssh-keys-persistent/ssh_host_rsa_key ]; then
    echo ">>> Restaurando chaves SSH persistentes..."
    cp -f /ssh-keys-persistent/ssh_host_* /etc/ssh/keys/ || echo ">>> Aviso: Falha ao copiar chaves SSH"
    chmod 600 /etc/ssh/keys/*_key || echo ">>> Aviso: Falha ao ajustar permissões das chaves"
    chmod 644 /etc/ssh/keys/*.pub || echo ">>> Aviso: Falha ao ajustar permissões dos pubs"
    chown root:root /etc/ssh/keys/* || echo ">>> Aviso: Falha ao ajustar dono das chaves"
else
    echo ">>> Gerando novas chaves SSH..."
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/keys/ssh_host_rsa_key -N "" && \
    ssh-keygen -t ed25519 -f /etc/ssh/keys/ssh_host_ed25519_key -N "" && \
    cp /etc/ssh/keys/ssh_host_* /ssh-keys-persistent/
fi

# Configuração do SSHD
echo ">>> Configurando SSHD..."
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
echo "AllowUsers jenkins" >> /etc/ssh/sshd_config

# Garante que o diretório .ssh do jenkins existe
mkdir -p /home/jenkins/.ssh
chown jenkins:jenkins /home/jenkins/.ssh
chmod 700 /home/jenkins/.ssh