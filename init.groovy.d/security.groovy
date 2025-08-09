import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

// Cria usuário admin
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(System.getenv('JENKINS_ADMIN_ID'), System.getenv('JENKINS_ADMIN_PASSWORD'))
instance.setSecurityRealm(hudsonRealm)

// Configura autorização
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)

instance.save()