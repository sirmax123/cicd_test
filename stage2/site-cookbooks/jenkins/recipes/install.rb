
yum_repository 'jenkins' do
  description "Jenkins Repo"
  baseurl     "http://pkg.jenkins-ci.org/redhat"
  gpgkey      "https://jenkins-ci.org/redhat/jenkins-ci.org.key"
  action      :create
end

# Move hardcod to params!
yum_package 'jenkins = 1.658-1.1'

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
  username       'jenkins'
  private_key    node['jenkins']['private_key']
  description    'Main SSH key one-for-all'
  action         :create
end



jenkins_credentials 'nexus_user' do
  admin_user     node['jenkins']['admin_user']
  admin_password node['jenkins']['admin_password']
  username       node['jenkins']['nexus_user']['username']
  password       node['jenkins']['nexus_user']['password']
  description    'nexus_user'
  action         :create
end



node['jenkins']['plugins'].each do |jenkins_plugin|
  puts(jenkins_plugin)
  jenkins_plugin "#{jenkins_plugin}" do
    username node['jenkins']['admin_user']
    password node['jenkins']['admin_password']
    action   :install
  end
end


jenkins_safe_restart 'restart' do
  admin_user     node['jenkins']['admin_user']
  admin_password node['jenkins']['admin_password']
  action         :do_safe_restart
end
