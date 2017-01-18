property :name, String
property :username, String, default: ''
property :password, String, default: ''
property :jenkins_url, String, default: 'http://127.0.0.1:8080/'


action :install do
  if   password.length > 0 && username.length > 0 
    install_command = "/usr/bin/java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s #{jenkins_url}  install-plugin #{name} --username=#{username} --password=#{password}"
  else
    install_command = "/usr/bin/java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s #{jenkins_url}  install-plugin #{name}"
  end
  puts("Install plugin #{name}")
  res = `#{install_command}`
  puts(res)
end


action :uninstall do
  puts("Not implemented")
end
