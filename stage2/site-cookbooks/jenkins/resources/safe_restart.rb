property :admin_user, String, default: ''
property :admin_password, String, default: ''
property :jenkins_url, String, default: 'http://127.0.0.1:8080/'


action :do_safe_restart  do
  if admin_password.length > 0 && admin_user.length > 0
    jenkins_cli = get_jenkins_cli() + " -s #{jenkins_url}  safe-restart --username=#{admin_user} --password=#{admin_password}"
  else
    jenkins_cli = get_jenkins_cli() + " -s #{jenkins_url}  safe-restart"
  end
  cmd = " #{jenkins_cli}"
  res = `#{cmd}`
end


