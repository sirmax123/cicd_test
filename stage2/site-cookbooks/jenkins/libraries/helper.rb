def get_jenkins_cli()
  return " /usr/bin/java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar "

end
def get_lib()

groovy_code_lib = """

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
        new SchemeRequirement(\\\"ssh\\\")
      )
    
    return CredentialsMatchers.firstOrNull(
      available_credentials,
      username_matcher
    )
  }





  /////////////////////////
  // create or update user
  /////////////////////////
  void create_or_update_user(String user_name, String email, String password=\\\"\\\", String full_name=\\\"\\\", String public_keys=\\\"\\\") {
    def user = hudson.model.User.get(user_name)
    user.setFullName(full_name)
    
    def email_param = new hudson.tasks.Mailer.UserProperty(email)
    user.addProperty(email_param)
    
    def pw_param = hudson.security.HudsonPrivateSecurityRealm.Details.fromPlainPassword(password)
    user.addProperty(pw_param)
    
    if ( public_keys != \\\"\\\" ) {
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
      keys = keysProperty.authorizedKeys.split('\\\\\\\\s+')
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
  void create_or_update_credentials(String username, String password, String id, String description=\\\"\\\", String private_key=\\\"\\\") {
    def global_domain = Domain.global()
    def credentials_store =
      Jenkins.instance.getExtensionList(
        'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
      )[0].getStore()
    
    def credentials
    if (private_key == \\\"\\\" ) {
      credentials = new UsernamePasswordCredentialsImpl(
        CredentialsScope.GLOBAL,
        id,
        description,
        username,
        password
      )
    } else {
      def key_source
      out.println(private_key)
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

"""


  return groovy_code_lib
end



def get_install_maven_lib()

install_maven_lib =  """

import hudson.tasks.Maven.MavenInstallation;
import hudson.tools.InstallSourceProperty;
import hudson.tools.ToolProperty;
import hudson.tools.ToolPropertyDescriptor;
import hudson.util.DescribableList;
import jenkins.model.*


// Try to do this code idempotent (to be able to use it in chef)

def addMavenIfNotExist(String mavenName, String mavenVersion) {
// Workaround? Class name is depends on installation name and looks like
// MavenInstallation[<name here>], e.g. MavenInstallation[M3] if name of maven is M3

  expectedClassName = \\\"MavenInstallation[\\\"+ mavenName + \\\"]\\\"


  def mavenDesc = jenkins.model.Jenkins.instance.getExtensionList(hudson.tasks.Maven.DescriptorImpl.class)[0]

  boolean isInstalled = false

  for ( currentInstallation in mavenDesc.installations ) {
    currentInstallationName = currentInstallation.toString()

    if (currentInstallationName == expectedClassName ) {
      //out.println(\\\"Alredy installed\\\")
      isInstalled = true
      //out.println(isInstalled)
    }
    else {
      out.println(\\\"Not installed\\\")
      //out.println(isInstalled)
    }
    //out.println(\\\"=======================\\\")
    //out.println(currentInstallation.getProperties().toString())
  }


  //out.println(isInstalled)
  if (! isInstalled) {
    out.println('Installing')
    def currentInstallSourceProperty = new InstallSourceProperty()
    def autoInstaller = new hudson.tasks.Maven.MavenInstaller(\\\"3.3.9\\\")
    currentInstallSourceProperty.installers.add(autoInstaller)
    //
    def proplist = new DescribableList<ToolProperty<?>, ToolPropertyDescriptor>()
    proplist.add(currentInstallSourceProperty)
    //
    def installation = new MavenInstallation(mavenName, \\\"\\\", proplist)
    def installations = (mavenDesc.installations as List);
    installations.add(installation)
    out.println(installations)


    mavenDesc.installations = installations
    mavenDesc.save()
  } else {
    out.println('Maven ' + mavenName + ' already installed')
  }
}

// Example
//addMavenIfNotExist('M3', '3.3.3')

"""
end