FROM tjleite87/jenkins:1.0.0

USER root

# Install packages and configure repositories
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
        jq && \
    # Docker repo
    curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
        https://download.docker.com/linux/debian/gpg && \
    echo "deb [arch=$(dpkg --print-architecture) \
        signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
        https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    # Adoptium repo
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | \
        gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] \
        https://packages.adoptium.net/artifactory/deb \
        $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | \
        tee /etc/apt/sources.list.d/adoptium.list && \
    # Install runtime packages
    apt-get update && \
    apt-get install -y \
        temurin-17-jdk \
        docker-ce-cli && \
    # Cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure Jenkins user
RUN mkdir -p /home/jenkins && \
    useradd -m -d /home/jenkins/slave -s /bin/bash jenkins && \
    echo "jenkins:jenkins" | chpasswd && \
    mkdir -p /home/jenkins/slave/.ssh && \
    chown -R jenkins:jenkins /home/jenkins/slave && \
    chmod 700 /home/jenkins/slave/.ssh && \
    # Sudo configuration
    echo "jenkins ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/jenkins && \
    chmod 440 /etc/sudoers.d/jenkins

# SSH configuration
RUN mkdir -p /etc/ssh/keys && \
    ssh-keygen -A -f /etc/ssh/keys

# Automatic connection setup
COPY automatic_agent_setup.sh /usr/local/bin/automatic_agent_setup.sh
RUN chmod +x /usr/local/bin/automatic_agent_setup.sh

# Environment setup
ENV JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64 \
    PATH=$JAVA_HOME/bin:$PATH \
    JENKINS_MASTER_URL=http://jenkins-master:8080 \
    JENKINS_AGENT_NAME=jenkins-slave \
    JENKINS_AGENT_WORKDIR=/home/jenkins/slave/workspace

# Entrypoint setup
COPY slave_entrypoint.sh /slave_entrypoint.sh
RUN chmod +x /slave_entrypoint.sh

VOLUME /home/jenkins/slave /etc/ssh/keys

EXPOSE 22

USER jenkins

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD netstat -tuln | grep -q ':22' || exit 1

ENTRYPOINT ["/slave_entrypoint.sh"]