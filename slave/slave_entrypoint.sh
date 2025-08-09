#!/bin/bash
set -e

# Restaura chaves SSH
/usr/local/bin/restore-ssh-keys.sh

# Prepara diretórios SSH
mkdir -p /run/sshd
chmod 755 /run/sshd

# Inicia SSH
echo ">>> Iniciando SSH Daemon..."
exec /usr/sbin/sshd -D -e &

# Espera SSH estar pronto
echo ">>> Aguardando SSH estar pronto..."
while ! netstat -tuln | grep -q ':22'; do
    sleep 1
done

# Configuração automática
if [ "$AUTO_REGISTER_AGENT" = "true" ]; then
    echo ">>> Iniciando configuração automática..."
    /usr/local/bin/automatic_agent_setup.sh
fi

# Mantém o container rodando
exec tail -f /dev/null