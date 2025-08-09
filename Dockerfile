# Camada 1: Base image (mantida exatamente como na original)
FROM jenkins/jenkins:lts-jdk17

# Camada 2: Configuração inicial do sistema (idêntica à original)
USER root
RUN apt-get update && \
    apt-get install -y \
        lsb-release \
        ca-certificates \
        curl \
        gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Camada 3: Configuração de repositórios (modificação recomendada)
RUN mkdir -p /etc/apt/keyrings && \
    # Docker repo (mantido o caminho original conforme imagem base)
    curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
        https://download.docker.com/linux/debian/gpg && \
    echo "deb [arch=$(dpkg --print-architecture) \
        signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
        https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    # Adoptium repo (mantido conforme original)
    curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | \
        gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] \
        https://packages.adoptium.net/artifactory/deb \
        $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | \
        tee /etc/apt/sources.list.d/adoptium.list

# Camada 4: Instalação de pacotes principais (idêntica à original)
RUN apt-get update && \
    apt-get install -y \
        sudo \
        git \
        temurin-17-jdk \
        docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Camada 5: Plugins Jenkins (mantido igual à original)
RUN jenkins-plugin-cli --plugins \
        blueocean \
        docker-workflow \
        ssh-slaves \
        pipeline-aws \
        credentials-binding \
        git \
        workflow-aggregator && \
    # Limpeza de cache (substituição recomendada mas mantendo comportamento original)
    rm -rf /var/jenkins_home/plugins/*.lock \
           /var/jenkins_home/plugins/*.jpi.pinned

# Camadas 6-8 (mantidas exatamente como na original)
USER jenkins

ENV JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64 \
    PATH=$JAVA_HOME/bin:$PATH \
    JENKINS_HOME=/var/jenkins_home

COPY --chown=jenkins:jenkins init.groovy.d/ /var/jenkins_home/init.groovy.d/

USER jenkins

EXPOSE 8080 50000