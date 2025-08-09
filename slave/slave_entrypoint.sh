#!/bin/bash

# Inicia serviços como root
service ssh start

# Wait for SSH to be ready
while ! netstat -tuln | grep -q ':22'; do
    sleep 1
done

# Executa script de configuração automática
/usr/local/bin/automatic_agent_setup.sh

# Troca para usuário jenkins e executa o comando principal
exec gosu jenkins "$@"

# Keep container running
#tail -f /dev/null