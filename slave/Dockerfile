FROM tjleite87/jenkins:1.0.0

USER root

# Install required packages and configure repositories in a single RUN layer
RUN apt-get update && \
    apt-get install -y \
        git \
        lsb-release \
        ca-certificates \
        curl \
        sudo \
        gnupg \
        openssh-server && \
    # Configure Docker repository
    curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
        https://download.docker.com/linux/debian/gpg && \
    echo "deb [arch=$(dpkg --print-architecture) \
        signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
        https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    # Configure Adoptium repository
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | \
        gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] \
        https://packages.adoptium.net/artifactory/deb \
        $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | \
        tee /etc/apt/sources.list.d/adoptium.list && \
    # Install remaining packages
    apt-get update && \
    apt-get install -y \
        temurin-17-jdk \
        docker-ce-cli && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create jenkins user with proper home directory
RUN mkdir -p /home/jenkins && \
    useradd -m -d /home/jenkins/slave -s /bin/bash jenkins && \
    echo "jenkins:jenkins" | chpasswd && \
    mkdir -p /home/jenkins/slave/.ssh && \
    chown -R jenkins:jenkins /home/jenkins/slave && \
    chmod 700 /home/jenkins/slave/.ssh && \
    # Configure sudo securely
    echo "jenkins ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/jenkins && \
    chmod 440 /etc/sudoers.d/jenkins

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64 \
    PATH=$JAVA_HOME/bin:$PATH

# Copy and configure entrypoint
COPY slave_entrypoint.sh /slave_entrypoint.sh
RUN chmod +x /slave_entrypoint.sh

# Volume declaration (must be after user creation)
VOLUME /home/jenkins/slave/

EXPOSE 22

USER jenkins

ENTRYPOINT ["/slave_entrypoint.sh"]