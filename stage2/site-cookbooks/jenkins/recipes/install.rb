# access to dynamic slaves

route '10.0.10.0/24' do
  gateway '10.0.1.1'
end





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


# remove comment from this section!!!!!!!
#node['jenkins']['plugins'].each do |jenkins_plugin|
#  puts(jenkins_plugin)
#  jenkins_plugin "#{jenkins_plugin}" do
#    username node['jenkins']['admin_user']
#    password node['jenkins']['admin_password']
#    action   :install
#  end
#end


jenkins_maven 'M3' do
  version    '3.3.9'
  admin_user     node['jenkins']['admin_user']
  admin_password node['jenkins']['admin_password']
  action      :install
end


jenkins_maven 'M331' do
  version    '3.3.1'
  admin_user     node['jenkins']['admin_user']
  admin_password node['jenkins']['admin_password']
  action      :install
end




jenkins_safe_restart 'restart' do
  admin_user     node['jenkins']['admin_user']
  admin_password node['jenkins']['admin_password']
  action         :do_safe_restart
end



remote_file "wait Jenkins startup workaround 2" do
  path        "/tmp/jenkins_2"
  source      "http://127.0.0.1:8080/"
  retries     60
  retry_delay 10
  backup      false
end


## need to do this in better way, will fix

job_list  = [
  "build_chuck",
  "disable_security"
  ]

job_list.each do |current_job|
  template "/tmp/#{current_job}.xml" do
    source "#{current_job}.xml.erb"
    mode '0600'
    owner 'root'
    group 'root'
  end

  bash "#{current_job}" do
  code <<-EOH
    /usr/bin/java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/  \
    get-job #{current_job} \
    --username=#{node['jenkins']['admin_user']} \
    --password=#{node['jenkins']['admin_password']} || \
    cat /tmp/#{current_job}.xml | \
    /usr/bin/java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/  \
    create-job  #{current_job} \
    --username=#{node['jenkins']['admin_user']} \
    --password=#{node['jenkins']['admin_password']}
    EOH
  end
  
end
#
bash "disable_security" do
  code <<-EOH
  /usr/bin/java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/  \
  build disable_security \
  --username=#{node['jenkins']['admin_user']} \
  --password=#{node['jenkins']['admin_password']}
  EOH
end



# build chuck
bash "build_chuck" do
  code <<-EOH
  /usr/bin/java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/  \
  build build_chuck \
  --username=#{node['jenkins']['admin_user']} \
  --password=#{node['jenkins']['admin_password']}
  EOH
end



