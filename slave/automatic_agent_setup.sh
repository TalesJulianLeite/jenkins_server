#!/bin/bash
set -e

echo ">>> Starting automatic agent registration..."

# Wait for Jenkins master to be ready
while ! curl -sSf "$JENKINS_MASTER_URL" >/dev/null; do
    echo "Waiting for Jenkins master to be ready..."
    sleep 10
done

# Generate SSH key if not exists
if [ ! -f /home/jenkins/slave/.ssh/id_rsa ]; then
    echo "Generating new SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f /home/jenkins/slave/.ssh/id_rsa -N ""
    chmod 600 /home/jenkins/slave/.ssh/id_rsa*
    chown jenkins:jenkins /home/jenkins/slave/.ssh/id_rsa*
fi

# Get Jenkins CLI jar
JENKINS_CLI_JAR="/home/jenkins/jenkins-cli.jar"
curl -sSL "$JENKINS_MASTER_URL/jnlpJars/jenkins-cli.jar" -o "$JENKINS_CLI_JAR"

# Create credentials in Jenkins
CREDENTIALS_XML=$(cat <<EOF
<com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey>
  <scope>GLOBAL</scope>
  <id>${JENKINS_AGENT_NAME}-ssh-key</id>
  <username>jenkins</username>
  <privateKeySource class="com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource">
    <privateKey>$(cat /home/jenkins/slave/.ssh/id_rsa)</privateKey>
  </privateKeySource>
</com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey>
EOF
)

echo "Creating credentials in Jenkins..."
curl -sSL -X POST \
    -H "Content-Type: application/xml" \
    -d "$CREDENTIALS_XML" \
    "${JENKINS_MASTER_URL}/credentials/store/system/domain/_/createCredentials"

# Create agent node
NODE_JSON=$(cat <<EOF
{
    "name": "${JENKINS_AGENT_NAME}",
    "nodeDescription": "Automatically provisioned agent",
    "numExecutors": 2,
    "remoteFS": "${JENKINS_AGENT_WORKDIR}",
    "labelString": "docker linux",
    "mode": "NORMAL",
    "retentionStrategy": {
        "stapler-class": "hudson.slaves.RetentionStrategy\$Always"
    },
    "nodeProperties": {
        "stapler-class-bag": "true"
    },
    "launcher": {
        "stapler-class": "hudson.plugins.sshslaves.SSHLauncher",
        "host": "jenkins-slave",
        "port": 22,
        "credentialsId": "${JENKINS_AGENT_NAME}-ssh-key",
        "sshHostKeyVerificationStrategy": {
            "stapler-class": "hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy"
        }
    }
}
EOF
)

echo "Creating agent node in Jenkins..."
curl -sSL -X POST \
    -H "Content-Type: application/json" \
    -d "$NODE_JSON" \
    "${JENKINS_MASTER_URL}/computer/doCreateItem?name=${JENKINS_AGENT_NAME}&type=hudson.slaves.DumbSlave"

echo ">>> Agent registration complete!"