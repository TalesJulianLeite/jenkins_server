FROM tjleite87/jenkins:1.0.1

USER root

# Configura ambiente não-interativo para apt
ENV DEBIAN_FRONTEND=noninteractive

# Etapa 1: Atualizar sources.list e instalar dependências básicas (CORRIGIDO)
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
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Etapa 2: Configurar repositórios adicionais
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
        https://download.docker.com/linux/debian/gpg && \
    echo "deb [arch=$(dpkg --print-architecture) \
        signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
        https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | \
        gpg --dearmor -o /etc/apt/trusted.gpg.d/adoptium.gpg && \
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/adoptium.gpg] \
        https://packages.adoptium.net/artifactory/deb \
        $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" \
        > /etc/apt/sources.list.d/adoptium.list

# Etapa 3: Instalar pacotes principais
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        temurin-17-jdk \
        docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    unset DEBIAN_FRONTEND

# Configurar usuário Jenkins
RUN id -u jenkins >/dev/null 2>&1 || ( \
    groupadd -g 1000 jenkins && \
    useradd -m -d /home/jenkins -u 1000 -g 1000 -s /bin/bash jenkins ) && \
    mkdir -p /home/jenkins/slave/.ssh && \
    chown -R jenkins:jenkins /home/jenkins && \
    chmod 700 /home/jenkins/slave/.ssh && \
    echo "jenkins ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/jenkins && \
    chmod 440 /etc/sudoers.d/jenkins && \
    echo "jenkins:jenkins" | chpasswd

# Configuração SSH
RUN mkdir -p /etc/ssh/keys && \
    ssh-keygen -A -f /etc/ssh/keys

# Configuração automática
COPY --chown=jenkins:jenkins automatic_agent_setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/automatic_agent_setup.sh

# Variáveis de ambiente
ENV JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64 \
    PATH=$JAVA_HOME/bin:$PATH \
    JENKINS_MASTER_URL=http://jenkins-master:8080 \
    JENKINS_AGENT_NAME=jenkins-slave \
    JENKINS_AGENT_WORKDIR=/home/jenkins/slave/workspace

# Entrypoint
COPY --chown=jenkins:jenkins slave_entrypoint.sh /slave_entrypoint.sh
RUN chmod +x /slave_entrypoint.sh

VOLUME /home/jenkins/slave /etc/ssh/keys

EXPOSE 22

USER jenkins

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD netstat -tuln | grep -q ':22' || exit 1

ENTRYPOINT ["/slave_entrypoint.sh"]