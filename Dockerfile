# Camada 1: Base image
FROM tjleite87/jenkins:1.0.1

# Camada 2: Configuração inicial do sistema
USER root
RUN apt-get update && \
    apt-get install -y \
        lsb-release \
        ca-certificates \
        curl \
        gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Camada 3: Configuração de repositórios
RUN mkdir -p /etc/apt/keyrings && \
    # Docker repo
    curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
        https://download.docker.com/linux/debian/gpg && \
    echo "deb [arch=$(dpkg --print-architecture) \
        signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
        https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    # Adoptium repo
    curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | \
        gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] \
        https://packages.adoptium.net/artifactory/deb \
        $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | \
        tee /etc/apt/sources.list.d/adoptium.list

# Camada 4: Instalação de pacotes principais
RUN apt-get update && \
    apt-get install -y \
        sudo \
        git \
        temurin-17-jdk \
        docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Camada 5: Plugins Jenkins (camada mutável frequente)
RUN jenkins-plugin-cli --plugins \
        blueocean \
        docker-workflow \
        ssh-slaves \
        pipeline-aws \
        credentials-binding \
        git \
        workflow-aggregator && \
    # Limpeza de cache de plugins
    rm -rf /var/jenkins_home/plugins/*.lock \
           /var/jenkins_home/plugins/*.jpi.pinned

# Camada 6: Configuração de ambiente
ENV JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64 \
    PATH=$JAVA_HOME/bin:$PATH \
    JENKINS_HOME=/var/jenkins_home

# Camada 7: Configurações iniciais (camada mutável frequente)
COPY --chown=jenkins:jenkins init.groovy.d/ /var/jenkins_home/init.groovy.d/

# Camada 8: Finalização
USER jenkins
EXPOSE 8080 50000