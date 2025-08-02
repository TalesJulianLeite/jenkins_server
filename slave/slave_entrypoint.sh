#!/bin/bash
set -e

echo ">>> Configuring Jenkins Slave Environment <<<"

# 1. Directory Structure and Permissions
echo "[1/7] Setting up persistent volume structure..."
mkdir -p /home/jenkins/slave/{.ssh,workspace,.jenkins}
chown -R jenkins:jenkins /home/jenkins/slave
chmod 755 /home/jenkins/slave
chmod 700 /home/jenkins/slave/.ssh

# 2. Generate SSH Key Pair (if missing)
echo "[2/7] Configuring SSH keys..."
SSH_DIR="/home/jenkins/slave/.ssh"

if [ ! -f "$SSH_DIR/id_rsa" ]; then
    echo "-> Generating new SSH key pair in volume..."
    sudo -u jenkins ssh-keygen -t rsa -b 4096 -f "$SSH_DIR/id_rsa" -N ""
    chmod 600 "$SSH_DIR/id_rsa"
    echo "-> Public key:"
    sudo -u jenkins cat "$SSH_DIR/id_rsa.pub"
fi

# 3. Configure Authorized Keys
echo "[3/7] Setting up authorized_keys..."
if [ -n "$SSH_PUBLIC_KEY" ]; then
    echo "-> Adding provided SSH public key to authorized_keys"
    echo "$SSH_PUBLIC_KEY" > "$SSH_DIR/authorized_keys"
elif [ ! -f "$SSH_DIR/authorized_keys" ]; then
    echo "-> Using generated key as authorized_keys"
    sudo -u jenkins cp "$SSH_DIR/id_rsa.pub" "$SSH_DIR/authorized_keys"
fi

chmod 600 "$SSH_DIR/authorized_keys"
chown jenkins:jenkins "$SSH_DIR/authorized_keys"

# 4. Generate SSH Host Keys (persistent)
echo "[4/7] Configuring SSH host keys..."
mkdir -p /etc/ssh/keys
if [ ! -f "/etc/ssh/keys/ssh_host_rsa_key" ]; then
    echo "-> Generating new SSH host keys..."
    ssh-keygen -A -f /etc/ssh/keys
fi
ln -sf /etc/ssh/keys/* /etc/ssh/

# 5. SSH Daemon Configuration
echo "[5/7] Configuring SSH server..."
cat > /etc/ssh/sshd_config << 'EOL'
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
ChallengeResponseAuthentication no
X11Forwarding no
PrintMotd no
AllowUsers jenkins
EOL

# 6. Java Environment Setup
echo "[6/7] Configuring Java environment..."
export JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
update-alternatives --set java "$JAVA_HOME/bin/java"

# 7. Service Startup
echo "[7/7] Starting services..."
mkdir -p /var/log/sshd
/usr/sbin/sshd -D -E /var/log/sshd/sshd.log &

echo -e "\n>>> Jenkins Slave Ready <<<"
echo -e "=== Connection Details ==="
echo "SSH User: jenkins"
echo "SSH Port: 22"
echo "Persistent Volume: /home/jenkins/slave"
echo -e "\n=== SSH Public Key ==="
sudo -u jenkins cat "$SSH_DIR/id_rsa.pub"
echo -e "\n=== Java Version ==="
java -version

exec tail -f /dev/null