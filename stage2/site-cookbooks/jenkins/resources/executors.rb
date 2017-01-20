property :admin_user, String, default: ''
property :admin_password, String, default: ''
property :jenkins_url, String, default: 'http://127.0.0.1:8080/'

property :number, String, default: '10'
## remove hardcode like home etc.
action :set do
  groovy_code_lib = """
    import jenkins.model.*

    void set_executors(int number) {

    Jenkins jenkins = Jenkins.getInstance()
    jenkins.setNumExecutors(number)
    jenkins.save()
}

 set_executors(#{number})
"""  
  groovy_code =   """
  echo \"
    #{groovy_code_lib}
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
