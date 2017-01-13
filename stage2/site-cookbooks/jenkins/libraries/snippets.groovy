
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*;
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.*;
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.domains.*;
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.plugins.credentials.impl.*;
import hudson.plugins.sshslaves.*;
import jenkins.model.*;

class InvalidAuthenticationStrategy extends Exception {}


  private credentials_for_username(String username) {
    def username_matcher = CredentialsMatchers.withUsername(username)
    def available_credentials =
      CredentialsProvider.lookupCredentials(
        StandardUsernameCredentials.class,
        Jenkins.getInstance(),
        hudson.security.ACL.SYSTEM,
        new SchemeRequirement("ssh")
      )
    
    return CredentialsMatchers.firstOrNull(
      available_credentials,
      username_matcher
    )
  }





  /////////////////////////
  // create or update user
  /////////////////////////
  void create_or_update_user(String user_name, String email, String password="", String full_name="", String public_keys="") {
    def user = hudson.model.User.get(user_name)
    user.setFullName(full_name)
    
    def email_param = new hudson.tasks.Mailer.UserProperty(email)
    user.addProperty(email_param)
    
    def pw_param = hudson.security.HudsonPrivateSecurityRealm.Details.fromPlainPassword(password)
    user.addProperty(pw_param)
    
    if ( public_keys != "" ) {
      def keys_param = new org.jenkinsci.main.modules.cli.auth.ssh.UserPropertyImpl(public_keys)
      user.addProperty(keys_param)
    }
    
    user.save()
  }
  
  /////////////////////////
  // delete user
  /////////////////////////
  void delete_user(String user_name) {
    def user = hudson.model.User.get(user_name, false)
    if (user != null) {
      user.delete()
    }
  }
  
  /////////////////////////
  // current user
  /////////////////////////
  void user_info(String user_name) {
    def user = hudson.model.User.get(user_name, false)
  
    if(user == null) {
        return null
    }

    def user_id = user.getId()
    def name = user.getFullName()
    
    def email_address = null
    def emailProperty = user.getProperty(hudson.tasks.Mailer.UserProperty)
    if(emailProperty != null) {
      email_address = emailProperty.getAddress()
    }
    
    def keys = null
    def keysProperty = user.getProperty(org.jenkinsci.main.modules.cli.auth.ssh.UserPropertyImpl)
    if(keysProperty != null) {
      keys = keysProperty.authorizedKeys.split('\\s+')
    }

    def token = null
    def tokenProperty = user.getProperty(jenkins.security.ApiTokenProperty.class)
    if (tokenProperty != null) {
        token = tokenProperty.getApiToken()
    }
    
    def builder = new groovy.json.JsonBuilder()
    builder {
      id user_id
      full_name name
      email email_address
      api_token token
      public_keys keys
    }
  
    out.println(builder)
  }
  
  /////////////////////////
  // create credentials
  /////////////////////////
  void create_or_update_credentials(String username, String password, String id, String description="", String private_key="") {
    out.println(id)
    def global_domain = Domain.global()
    def credentials_store =
      Jenkins.instance.getExtensionList(
        'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
      )[0].getStore()

    def credentials
    if (private_key == "" ) {
      credentials = new UsernamePasswordCredentialsImpl(
        CredentialsScope.GLOBAL,
        id,
        description,
        username,
        password
      )
    } else {
      def key_source
      if (private_key.startsWith('-----BEGIN')) {
        key_source = new BasicSSHUserPrivateKey.DirectEntryPrivateKeySource(private_key)
      } else {
        key_source = new BasicSSHUserPrivateKey.FileOnMasterPrivateKeySource(private_key)
      }
      credentials = new BasicSSHUserPrivateKey(
        CredentialsScope.GLOBAL,
        id,
        username,
        key_source,
        password,
        description
      )
    }
    
    // Create or update the credentials in the Jenkins instance
    def existing_credentials = credentials_for_username(username)
    
    if(existing_credentials != null) {
      credentials_store.updateCredentials(
        global_domain,
        existing_credentials,
        credentials
      )
    } else {
      credentials_store.addCredentials(global_domain, credentials)
    }
  }
  
  //////////////////////////
  // delete credentials
  //////////////////////////
  void delete_credentials(String username) {
    def existing_credentials = credentials_for_username(username)
    
    if(existing_credentials != null) {
      def global_domain = com.cloudbees.plugins.credentials.domains.Domain.global()
      def credentials_store =
        Jenkins.instance.getExtensionList(
          'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
        )[0].getStore()
      credentials_store.removeCredentials(
        global_domain,
        existing_credentials
      )
    }
  }
  
  ////////////////////////
  // current credentials
  ////////////////////////
  void credential_info(String username) {
    def credentials = credentials_for_username(username)
    
    if(credentials == null) {
      return null
    }
    
    def current_credentials = [
      id:credentials.id,
      description:credentials.description,
      username:credentials.username
    ]
  
    if ( credentials.hasProperty('password') ) {
    current_credentials['password'] = credentials.password.plainText
    } else {
      current_credentials['private_key'] = credentials.privateKey
      current_credentials['passphrase'] = credentials.passphrase.plainText
    }
  
    def builder = new groovy.json.JsonBuilder(current_credentials)
    out.println(builder)
  }
  
  ////////////////////////
  // set_security
  ////////////////////////
  /*
   * Set up security for the Jenkins instance. This currently supports
   * only a small number of configurations. If authentication is enabled, it
   * uses the internal user database.
  */
  void set_security(String security_model) {
    def instance = Jenkins.getInstance()

    if (security_model == 'disabled') {
      instance.disableSecurity()
      return null
    }

    def strategy
    def realm
    switch (security_model) {
      case 'full_control':
        strategy = new hudson.security.FullControlOnceLoggedInAuthorizationStrategy()
        realm = new hudson.security.HudsonPrivateSecurityRealm(false, false, null)
        break
      case 'unsecured':
        strategy = new hudson.security.AuthorizationStrategy.Unsecured()
        realm = new hudson.security.HudsonPrivateSecurityRealm(false, false, null)
        break
      default:
        throw new InvalidAuthenticationStrategy()
    }
    instance.setAuthorizationStrategy(strategy)
    instance.setSecurityRealm(realm)
  }

String ssh_key = """-----BEGIN RSA PRIVATE KEY-----
MIIEoQIBAAKCAQEA0V39xz6tKyxDtg7psKpxeLm1i/1n/dFIf0wpE9vZtWxcypgu
pc0p0OvhztcWHUcJ/mUisipsjQb4bdpGbixjA9rhXG4fTeJVRsxd9+NawtDcSyVL
fDdZVRfgPmOZS6k/XpmzLksEtXDHVySUWybQjTMO26VwlWVpNRnFUg3LdeMEvny1
AgfcbBuhXG/yPPJhcNmz5Ez666eefGRzW74SuwwuKzYdtbmPLMpQ3AolNeJeL7ot
6Z3fF4uDVvtxVAcGvlLE9zR3gRcI4Mv2E5rPvgy6pumWDOyRtsFM8phNj+zZWMm8
jQCXSL6+W2lxznEnLMaI73IoY5XaraisCOt27wIBIwKCAQAX7XwWxVWeiLdIAbRO
tGS9Vw1vFaV8F+sHO+dv+95d4H+iIAVUxv129mLzEURbHg/FTWMNDCmpt6ddAwC8
IlR1eBnBa6vOYwJufcGYrETjEI40eUp0mJx+wOZth7m/gQ6Od/c4fZojXVicPrHe
iBfVn29pj0AREudzyG5ShTvS9Sqq7gQl764Fj4CN/IuqfJ3JbABSiNAYSHScY+1z
1csQokhqh0Je7phjcGGU4K+iuUXg4DwcfbXLsww6WRn0Ozyjqlpc3oqJgMWIPhSj
Pe4WXtVPgTBSxt0y3KFf6PQMGcUk8JZiQsg9KBXO6f5oTpkBGJpHw8xnQalPgNxW
exVLAoGBAPELc9rZBSi9fWujEPHlF5zzlnLUg4ac4P290jTWpTaQ8dH8rvjSZb9o
BzVKS4QUUR0FTAV4bmlWzrx5NaErn5A3x0T797woXrMGcdqcaq89u+SYdf/B8YNW
VqoDbOuGaPuV8nc2Zd+DEme2VS2l1i9xc9QxwreEIVKFl/UaJw5nAoGBAN5bZjXd
EYD99pDe/TpEGF/a0j49nFd6TKRmJ+DPiitYjmKKZ6AkrBpeq8W7EKBRvB26xBp3
438KXhvfOi0PYSPueOlOoX8lkZVyOubi0j08kwuWyS92rv7jYB7n9QqfomC/niF6
0l+ujZfSlNIX6zzxu27JvjRX9f6waS76D245AoGBANxiPgnq/WcTpd7A+Yy0Mtik
McgSwWUht8NruN/aMKbq67isgrebyr2g8KXARQsLQti0YsMsR7DEZT6atLCc6aht
gv0+JFRCKrJPCQJjH7Yp0Fv5G21+HqP3KqoRwqtzky8qAkEbytr7foq1VTEMppHG
0Ez6S6B4zgJOQcomihvLAoGAUpb6FAGnamz1Ln6109AmT30phNUOLx7MAoxX9GpX
5DbVzNRSYA2fAnrvWBJIAQhqcXFBhiyHstf3EaqvNU7a8Ba/MhXkNopMBE7/71uP
6tv8Gj9SClCnZfyurGTIus2UFU58kBetOXtZKcM+ly10oZudY6oE0Z0DmRzz3j+f
VNMCgYAln5mCtRGCYyKEdLH59zttFnvA2qGAmikSwpEkfhiMsfQQx0Rz/OhD3mXJ
51tQ4R1yz6kaoPPIIRVbidvBHl9KvAvwSqQxCpqQeW2xjgsdYOXY36f5rcjz8NQ+
aeUu0lJq8azIrMNTcqTjiZuJw0xBkbNQy392FQx7WolSnQtVHw==
-----END RSA PRIVATE KEY-----"""
//out.println(ssh_key)

//create_or_update_credentials(username='test', password='', description="descr", private_key=ssh_key)

create_or_update_credentials(username='test3',  password='test123', id='test_user_mm_123', description="descr hui vam", private_key="")


