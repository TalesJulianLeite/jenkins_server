FROM jenkins/ssh-agent:latest-jdk17

USER root

ENV DEBIAN_FRONTEND=noninteractive

# 1. Configuração do repositório Docker
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update

# 2. Instalação de dependências
RUN apt-get install -y --no-install-recommends \
        docker-ce-cli \
        openssh-server \
        git \
        make \
        build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 3. Configuração do diretório principal
RUN mkdir -p /home/jenkins/slave && \
    chown jenkins:jenkins /home/jenkins/slave

# 4. Configuração do SSH
RUN mkdir -p /etc/ssh/keys && \
    ssh-keygen -t ed25519 -f /etc/ssh/keys/ssh_host_ed25519_key -N "" && \
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/keys/ssh_host_rsa_key -N "" && \
    chown jenkins:jenkins /etc/ssh/keys/* && \
    chmod 600 /etc/ssh/keys/*_key && \
    chmod 644 /etc/ssh/keys/*.pub

# 5. Configuração do Docker
RUN groupadd -g 998 docker && \
    usermod -aG docker jenkins && \
    # Adiciona verificação para Docker-in-Docker
    [ -S /var/run/docker.sock ] && chown root:docker /var/run/docker.sock || true

# 6. Cópia dos scripts
COPY ./scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/slave-entrypoint.sh && \
    chmod +x /usr/local/bin/restore-ssh-keys.sh && \
    chown jenkins:jenkins /usr/local/bin/*

# 7. Configuração final
USER jenkins
WORKDIR /home/jenkins/slave

ENV JENKINS_AGENT_WORKDIR=/home/jenkins/slave \
    PATH="/home/jenkins/.local/bin:${PATH}"

HEALTHCHECK --interval=30s --timeout=10s \
    CMD ps aux | grep '[j]ava.*agent' || exit 1

EXPOSE 22 2222

ENTRYPOINT ["slave-entrypoint.sh"]