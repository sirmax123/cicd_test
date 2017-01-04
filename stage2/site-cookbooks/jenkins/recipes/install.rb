git "/tmp/petclinic-src" do
  repository "https://github.com/CloudBees-community/spring-petclinic.git"
  reference "master"
  action :sync
end






yum_repository 'jenkins' do
  description "Jenkins Reoi"
  baseurl "http://pkg.jenkins-ci.org/redhat"
  gpgkey 'https://jenkins-ci.org/redhat/jenkins-ci.org.key'
  action :create
end

yum_package 'jenkins = 1.658-1.1'

service "jenkins" do
  action [:start, :enable]
end


jenkins_security 'root'  do
  admin_user node['jenkins']['admin_user']
  admin_password node['jenkins']['admin_password']
  action :enable
end


remote_file "wait AdminServer startup" do
  path "/tmp/testfile"
  source "http://127.0.0.1:8080/"
  retries 60
  retry_delay 10
  backup false
end


jenkins_credentials 'jenkins_main_ssh_key' do
  admin_user node['jenkins']['admin_user']
  admin_password node['jenkins']['admin_password']
  username 'jenkins'
  private_key node['jenkins']['private_key']
  description 'Main SSH key one-for-all'
  action :create
end

node['jenkins']['plugins'].each do |jenkins_plugin|
  puts(jenkins_plugin)
  jenkins_plugin "#{jenkins_plugin}" do
    username node['jenkins']['admin_user']
    password node['jenkins']['admin_password']
    action :install
  end
end


jenkins_safe_restart 'restart' do
  action  :do_safe_restart
end



