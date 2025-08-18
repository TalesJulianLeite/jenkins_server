# Utiliza a imagem oficial do Jenkins com JDK17
FROM jenkins/jenkins:latest-jdk21

# Configuração como root para instalações iniciais
USER root

# 1. Instalação de dependências do sistema
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        git \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 2. Configuração do SSH
RUN mkdir -p /var/jenkins_home/.ssh && \
    ssh-keygen -A -t rsa -b 4096 && \
    ssh-keygen -A -t ed25519 && \
    mv /etc/ssh/ssh_host_* /var/jenkins_home/.ssh/ && \
    chown -R jenkins:jenkins /var/jenkins_home/.ssh && \
    chmod 700 /var/jenkins_home/.ssh && \
    chmod 600 /var/jenkins_home/.ssh/*

# 3. Configuração do diretório de inicialização
RUN mkdir -p /var/jenkins_home/init.groovy.d && \
    chown jenkins:jenkins /var/jenkins_home/init.groovy.d

# 4. Cópia dos scripts de configuração
COPY ./security.groovy /var/jenkins_home/init.groovy.d/
RUN chown jenkins:jenkins /var/jenkins_home/init.groovy.d/security.groovy

# 5. Instalação de plugins essenciais
RUN jenkins-plugin-cli --plugins \
        ssh-slaves \
        matrix-auth \
        workflow-aggregator \
        blueocean \
        pipeline-aws \
        docker-workflow && \
    rm -rf /var/jenkins_home/plugins/*.lock

# 6. Configuração de portas
EXPOSE 8080 50000 2223

# 7. Configuração final
USER jenkins

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV JENKINS_HOME="/var/jenkins_home"

# 8. Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/login || exit 1

WORKDIR /var/jenkins_home