# Use apenas um FROM (escolha a imagem base correta)
FROM tjleite87/jenkins-slave:1.0.1

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Etapa 1: Atualizar sources.list e instalar dependências básicas
RUN apt-get update && \
    apt-get install -y \
        git \
        lsb-release \
        ca-certificates \
        curl \
        sudo \
        gnupg \
        openssh-server \
        net-tools \
        jq \
        wget \
        software-properties-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Etapa 2: Configurar repositórios adicionais
RUN apt-get update && apt-get upgrade -y && \
    mkdir -p /etc/apt/keyrings && \
    # Repositório Docker
    curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
        https://download.docker.com/linux/debian/gpg && \
    echo "deb [arch=$(dpkg --print-architecture) \
        signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
        https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    # Repositório Adoptium
    apt-get update && \
    apt-get install -y --no-install-recommends apt-transport-https && \
    wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | \
        gpg --batch --dearmor -o /usr/share/keyrings/adoptium.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] \
        https://packages.adoptium.net/artifactory/deb \
        $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" \
        > /etc/apt/sources.list.d/adoptium.list && \
    apt-get update

# Etapa 3: Instalar pacotes principais
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        temurin-17-jdk \
        docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    unset DEBIAN_FRONTEND

# Configurar usuário Jenkins
RUN getent group jenkins || groupadd -g 1000 jenkins && \
    getent passwd jenkins || useradd -m -d /home/jenkins -u 1000 -g 1000 -s /bin/bash jenkins && \
    getent group sudo || groupadd sudo && \
    usermod -aG sudo jenkins && \
    mkdir -p /home/jenkins/slave/.ssh && \
    chown -R jenkins:jenkins /home/jenkins && \
    chmod 700 /home/jenkins/slave/.ssh && \
    echo "jenkins ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/jenkins && \
    chmod 440 /etc/sudoers.d/jenkins && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/sudo-group

# Configuração SSH
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server && \
    mkdir -p /etc/ssh/keys && \
    mkdir -p /ssh-keys-persistent && \
    # Gera chaves RSA e ED25519 explicitamente
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/keys/ssh_host_rsa_key -N "" && \
    ssh-keygen -t ed25519 -f /etc/ssh/keys/ssh_host_ed25519_key -N "" && \
    # Copia chaves para persistência
    cp /etc/ssh/keys/ssh_host_* /ssh-keys-persistent/ && \
    # Aplica permissões corretas
    chmod 600 /etc/ssh/keys/*_key /ssh-keys-persistent/*_key && \
    chmod 644 /etc/ssh/keys/*.pub /ssh-keys-persistent/*.pub && \
    chown root:root /etc/ssh/keys/* /ssh-keys-persistent/*

# Scripts de configuração
COPY --chown=root:root restore-ssh-keys.sh /usr/local/bin/
COPY --chown=jenkins:jenkins automatic_agent_setup.sh /usr/local/bin/
COPY --chown=root:root slave_entrypoint.sh /

RUN chmod +x /usr/local/bin/restore-ssh-keys.sh /usr/local/bin/automatic_agent_setup.sh /slave_entrypoint.sh

USER jenkins

# Variáveis de ambiente
ENV JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64 \
    PATH=$JAVA_HOME/bin:$PATH \
    JENKINS_AGENT_WORKDIR=/home/jenkins/slave \
    JENKINS_MASTER_URL=http://jenkins-master:8080 \
    JENKINS_AGENT_NAME=jenkins-slave

# Volumes
VOLUME /home/jenkins/slave
VOLUME /etc/ssh/keys
VOLUME /ssh-keys-persistent

EXPOSE 22

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=5 \
    CMD ss -tuln | grep -q ':22' || exit 1

ENTRYPOINT ["/bin/bash", "-c", "restore-ssh-keys.sh && /slave_entrypoint.sh"]