property :admin_user, String
property :admin_password, String
property :jenkins_url, String, default: 'http://127.0.0.1:8080/'



action :do_safe_restart  do

  jenkins_cli = get_jenkins_cli() + " -s #{jenkins_url}  safe-restart --username=#{admin_user} --password=#{admin_password}"

  cmd = " #{jenkins_cli}"
  res = `#{cmd}`
end


