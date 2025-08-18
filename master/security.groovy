import jenkins.model.*
import hudson.security.*
import org.jenkinsci.main.modules.cli.auth.ssh.*

def instance = Jenkins.getInstance()

def sshRealm = new SSHAuthenticator() {
    boolean acceptsCredentials(String username, String publicKey) {
        def expectedKey = new File('/var/jenkins_home/.ssh/authorized_keys').text.trim()
        return publicKey.trim() == expectedKey
    }
}

def securityRealm = new CompositeSecurityRealm(new HudsonPrivateSecurityRealm(false))
securityRealm.addRealm(sshRealm)
instance.setSecurityRealm(securityRealm)

def strategy = new GlobalMatrixAuthorizationStrategy()
strategy.add(Jenkins.ADMINISTER, System.getenv('JENKINS_ADMIN_ID'))
instance.setAuthorizationStrategy(strategy)

instance.setCrumbIssuer(new hudson.security.csrf.DefaultCrumbIssuer(true))
instance.save()