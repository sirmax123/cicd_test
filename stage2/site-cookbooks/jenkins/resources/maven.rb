property :admin_user, String
property :admin_password, String
property :jenkins_url, String, default: 'http://127.0.0.1:8080/'

property :name, String
property :version, String, default: "3.3.3"

action :install do
  groovy_code_lib = get_install_maven_lib()
  jenkins_action = """
     addMavenIfNotExist(\\\"#{name}\\\", \\\"#{version}\\\")
  """ 

  groovy_code =   """
  echo \"
    #{groovy_code_lib}
    
    #{jenkins_action}
  \"  """
  
  jenkins_cli = get_jenkins_cli() + " -s #{jenkins_url} groovy = --username=#{admin_user} --password=#{admin_password}"

  cmd = "#{groovy_code} | #{jenkins_cli}"
  res = `#{cmd}`
end


action :uninstall do
  puts("Not implemented")
end
