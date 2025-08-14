#!/bin/bash
# restore-ssh-keys.sh (VERSÃO CORRIGIDA)

echo "Restaurando chaves SSH persistentes com sudo..."

# Usa sudo para copiar arquivos pertencentes a root
sudo cp /ssh-keys-persistent/* /etc/ssh/keys/

# Usa sudo para ajustar o dono e as permissões
sudo chown root:root /etc/ssh/keys/*
sudo chmod 600 /etc/ssh/keys/*_key
sudo chmod 644 /etc/ssh/keys/*.pub

echo "Permissões das chaves SSH ajustadas com sucesso."