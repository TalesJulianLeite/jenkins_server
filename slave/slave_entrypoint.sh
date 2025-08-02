#!/bin/bash
set -e

# Initialize SSH
mkdir -p /home/jenkins/slave/.ssh
chmod 700 /home/jenkins/slave/.ssh
chown -R jenkins:jenkins /home/jenkins/slave

# Start SSH in background
/usr/sbin/sshd -D -e &

# Wait for SSH to be ready
while ! netstat -tuln | grep -q ':22'; do
    sleep 1
done

# Automatic agent registration
if [ "$AUTO_REGISTER_AGENT" = "true" ]; then
    /usr/local/bin/automatic_agent_setup.sh
fi

# Keep container running
tail -f /dev/null