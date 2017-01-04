property :admin_user, String
property :admin_password, String
property :jenkins_url, String, default: 'http://127.0.0.1:8080/'


action :enable do


  groovy_code =   """
  echo '
  import jenkins.model.*
  import hudson.security.*
  def instance = Jenkins.getInstance()
  def hudsonRealm = new HudsonPrivateSecurityRealm(false)
  hudsonRealm.createAccount(\"#{admin_user}\", \"#{admin_password}\")
  instance.setSecurityRealm(hudsonRealm)
  strategy = new hudson.security.FullControlOnceLoggedInAuthorizationStrategy()
  instance.setAuthorizationStrategy(strategy)
  instance.save()
  '  """
  
  jenkins_cli = "java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s #{jenkins_url} groovy = --username=#{admin_user} --password=#{admin_password}"

  cmd = "#{groovy_code} | #{jenkins_cli}"
  puts(cmd)
  res = `#{cmd}`
  puts(res)
end


action :disable do
  puts("Not implemented")
end
