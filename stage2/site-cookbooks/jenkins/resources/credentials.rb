property :admin_user, String, default: ''
property :admin_password, String, default: ''
property :jenkins_url, String, default: 'http://127.0.0.1:8080/'

property :username, String
property :password, String, default: ""
property :description, String, default: ""
property :private_key, String, default: ""

action :create do
  groovy_code_lib = get_lib()
  jenkins_action = """
    String ssh_private_key = \\\"\\\"\\\"#{private_key}\\\"\\\"\\\"
    create_or_update_credentials(username=\\\"#{username}\\\",  password=\\\"#{password}\\\", id=\\\"#{name}\\\", description=\\\"#{description}\\\", private_key=ssh_private_key)
  """ 

  groovy_code =   """
  echo \"
    #{groovy_code_lib}
    
    #{jenkins_action}
  \"  """
  
  puts(groovy_code)
  
  if admin_password.length > 0 && admin_user.length > 0
    jenkins_cli = get_jenkins_cli() + " -s #{jenkins_url} groovy = --username=#{admin_user} --password=#{admin_password}"
  else
      jenkins_cli = get_jenkins_cli() + " -s #{jenkins_url} groovy = "
  end
  cmd = "#{groovy_code} | #{jenkins_cli}"
  res = `#{cmd}`
end


action :delete do
  puts("Not implemented")
end
