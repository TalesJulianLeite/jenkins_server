#!/bin/bash
set -e

echo ">>> Starting SSH agent..."
eval $(ssh-agent -s)

echo ">>> Waiting for Jenkins master..."
while ! curl -sSf "$JENKINS_URL" >/dev/null; do
    sleep 5
done

echo ">>> Starting agent..."
exec java -jar /usr/share/jenkins/agent.jar \
    -workDir /home/jenkins/slave \
    -jnlpUrl "$JENKINS_URL/computer/$JENKINS_AGENT_NAME/slave.jnlp"