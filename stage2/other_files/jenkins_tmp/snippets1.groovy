
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
  
user_info(username="root")