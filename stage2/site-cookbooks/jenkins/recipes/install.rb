# access to dynamic slaves

route '10.0.10.0/24' do
  gateway '10.0.1.1'
end



#jenkins_build_job "build_chuck" do
#  admin_user     node['jenkins']['admin_user']
#  admin_password node['jenkins']['admin_password']
#  action :build
#end



yum_repository 'jenkins' do
  description "Jenkins Repo"
  baseurl     "http://pkg.jenkins-ci.org/redhat"
  gpgkey      "https://jenkins-ci.org/redhat/jenkins-ci.org.key"
  action      :create
end

# Move hardcod to params!
yum_package 'jenkins = 1.658-1.1'



template '/etc/sysconfig/jenkins' do
  source '/jenkins.erb'
  mode '0600'
  owner 'root'
  group 'root'
end


service "jenkins" do
  action [:start, :enable]
end


remote_file "wait Jenkins startup workaround" do
  path        "/tmp/testfile"
  source      "http://127.0.0.1:8080/"
  retries     60
  retry_delay 10
  backup      false
end



## w/o creds now
node['jenkins']['plugins'].each do |jenkins_plugin|
  puts(jenkins_plugin)
  jenkins_plugin "#{jenkins_plugin}" do
###    username node['jenkins']['admin_user']
###    password node['jenkins']['admin_password']
    action   :install
  end
end





jenkins_safe_restart 'restart' do
#  admin_user     node['jenkins']['admin_user']
#  admin_password node['jenkins']['admin_password']
  action         :do_safe_restart
end



remote_file "wait  jenkins_safe_restart_before_disable_security" do
  path        "/tmp/jenkins_safe_restart_before_disable_security"
  source      "http://127.0.0.1:8080/"
  retries     60
  retry_delay 10
  backup      false
end




## need to move to provider
bash "disable_security" do
  code <<-EOH
  echo org.jenkinsci.plugins.permissivescriptsecurity.PermissiveWhitelist.enabled=true | java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ groovy =
  EOH
end


## need to do this in better way, will fix

job_list  = [
  "add_dynamic_slave",
  "all",
  "build_petclinic",
  "build_tomcat",
  "check_node",
  "create_all_in_one_env",
  "c",
  "delete_slave",
  "deploy_petclininc",
  "deploy_tomcat",
  "destroy_all_in_one_node",
  "test_slave",
  "trigger",
  "up",
  "build_chuck"
  ]

job_list.each do |current_job|
  template "/tmp/#{current_job}.xml" do
    source "jobs/#{current_job}.xml.erb"
    mode '0600'
    owner 'root'
    group 'root'
  end

  bash "add #{current_job}" do
  code <<-EOH
    /usr/bin/java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ get-job #{current_job} || cat /tmp/#{current_job}.xml | /usr/bin/java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/  create-job  #{current_job}
    EOH
  end

end
#





jenkins_executors 'set_executors' do
  action :set
  number '9'
end



jenkins_maven 'M3' do
  version    '3.3.9'
#  admin_user     node['jenkins']['admin_user']
#  admin_password node['jenkins']['admin_password']
  action      :install
end


jenkins_maven 'M331' do
  version    '3.3.1'
#  admin_user     node['jenkins']['admin_user']
#  admin_password node['jenkins']['admin_password']
  action      :install
end



### Build Chuck
template '/tmp/build_chuck.groovy' do
  source '/build_chuck.groovy.erb'
  mode '0600'
  owner 'root'
  group 'root'
end


# build chuck
# code like
# /usr/bin/java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/  build   build_chuck
# does not work w/o ssh keys for some reason and I was not able to find how to add ssh keys
# so use this workaround
bash "build_chuck" do
  code <<-EOH
  cat /tmp/build_chuck.groovy | /usr/bin/java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ groovy =
  EOH
end

jenkins_safe_restart 'restart_after_plugins_install' do
  action         :do_safe_restart
end


remote_file "wait Jenkins startup after Chuck Added" do
  path        "/tmp/jenkins_0002"
  source      "http://127.0.0.1:8080/"
  retries     60
  retry_delay 10
  backup      false
end


# stop here!
#bash "manual_fail" do
#  code <<-EOH
#  false
#  EOH
#end










jenkins_security 'root'  do
  admin_user     node['jenkins']['admin_user']
  admin_password node['jenkins']['admin_password']
  action         :enable
end


jenkins_credentials 'jenkins_main_ssh_key' do
  admin_user     node['jenkins']['admin_user']
  admin_password node['jenkins']['admin_password']
  username       'jenkins_main'
  private_key    node['jenkins']['private_key']
  description    'Main SSH key one-for-all'
  action         :create
end


jenkins_credentials 'dynamic_slaves' do
  admin_user     node['jenkins']['admin_user']
  admin_password node['jenkins']['admin_password']
  username       'root'
  private_key    node['jenkins']['jenkins_slave_private_key']
  description    'creds_for_all_dynamic_slaves'
  action         :create
end



jenkins_credentials 'just_test_user' do
  admin_user     node['jenkins']['admin_user']
  admin_password node['jenkins']['admin_password']
  username       'user'
  password       'password'
  description    'user / password test user :)'
  action         :create
end


# hardcoded user
jenkins_credentials 'chucknorris' do
  admin_user     node['jenkins']['admin_user']
  admin_password node['jenkins']['admin_password']
  username       'chucknorris'
  password       'chucknorris'
  description    'Chuck Norris'
  action         :create
end


#==> jenkins:  {"vagrant"=>{"host"=>"10.0.2.2", "credentials"=>{"username"=>"jenkins", "password"=>"jenkins123"}}}
node['jenkins']['jenkins_slaves'].each do |current_jenkins_slave|

  Chef::Log.info(" ---\n\n #{current_jenkins_slave} \n\n ----")
  current_jenkins_slave.each do |jenkins_slave_name, jenkins_slave_data|
    Chef::Log.info(" ---\n\n #{jenkins_slave_name} \n\n ----")
    Chef::Log.info(" ---\n\n #{jenkins_slave_data} \n\n ----")

    Chef::Log.info(" ---\n\n #{jenkins_slave_data[:host]} \n\n ----")

  
    Chef::Log.info(" ---\n\n #{jenkins_slave_data[:credentials][:username]} \n\n ----")
    Chef::Log.info(" ---\n\n #{jenkins_slave_data[:credentials][:password]} \n\n ----")

    jenkins_credentials "SLAVE_USER_#{jenkins_slave_name}" do
      admin_user     node['jenkins']['admin_user']
      admin_password node['jenkins']['admin_password']
      username       "#{jenkins_slave_data[:credentials][:username]}"
      password       "#{jenkins_slave_data[:credentials][:password]}"
      description    "Slave User for #{jenkins_slave_name}"
      action         :create
    end

    jenkins_slave "#{jenkins_slave_name}" do
      admin_user     node['jenkins']['admin_user']
      admin_password node['jenkins']['admin_password']
      host           "#{jenkins_slave_data[:host]}"
      description    "SomeSlave"
      label          "#{jenkins_slave_name}"
      credentials    "SLAVE_USER_#{jenkins_slave_name}"
      action         :create
    end
  end
end



jenkins_safe_restart 'restart' do
  admin_user     node['jenkins']['admin_user']
  admin_password node['jenkins']['admin_password']
  action         :do_safe_restart
end



remote_file "wait Jenkins startup last check" do
  path        "/tmp/jenkins_999"
  source      "http://127.0.0.1:8080/"
  retries     60
  retry_delay 10
  backup      false
end



#jenkins_build_job "trigger" do
#  admin_user     node['jenkins']['admin_user']
#  admin_password node['jenkins']['admin_password']
#  action :build
#end
