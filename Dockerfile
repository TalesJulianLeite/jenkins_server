FROM tjleite87/jenkins:1.0.0
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli

# Atualiza os pacotes
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    openjdk-21-jdk \
    && apt-get clean
# Define a variável de ambiente JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow json-path-api"