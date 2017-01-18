route '10.0.10.0/24' do
  gateway '10.0.1.1'
end

deps = [
  "rpm-build",
  "rpmdevtools",
  "readline-devel",
  "ncurses-devel",
  "gdbm-devel",
  "tcl-devel",
  "openssl-devel",
  "db4-devel",
  "byacc",
  "libyaml-devel",
  "libffi-devel",
  "make"
]

jobs_to_be_added = [
  "add_slave.groovy",
  "all.groovy",
  "all_in_one_env.groovy",
  "build_chuck.groovy",
  "build_petclinic.groovy",
  "build_tomcat.groovy",
  "check_node.groovy",
  "delete_slave.groovy",
  "deploy_petclininc.groovy",
  "deploy_tomcat.groovy",
  "destroy_all_in_one_node.groovy",
  "test_slave.groovy",
  "up.groovy"
]





log 'message' do
  message "#{node}"
  level :info
end


deps.each do |p|
  package p do
    action :install
  end
end

#cookbook_file '/root/build_and_install_ruby_1_9_3.sh' do
#  source 'build_and_install_ruby_1_9_3.sh'
#  owner 'root'
#  group 'root'
#  mode '0755'
#  action :create
#end
#
#
#execute 'build_ruby' do
#  command '/root/build_and_install_ruby_1_9_3.sh'
#end

#template '/etc/gitlab/gitlab.rb' do
#  source '/gitlab.rb.erb'
#  mode '0600'
#  owner 'root'
#  group 'root'
#  variables({
#    external_url: "#{node['gitlab']['external_url']}",
#  })
#end




yum_repository 'gitlab_gitlab-ce' do
  description "Gitlab repo"
  baseurl "https://packages.gitlab.com/gitlab/gitlab-ce/el/6/$basearch"
  gpgkey "https://packages.gitlab.com/gitlab/gitlab-ce/gpgkey"
  gpgcheck false
  action :create
end


package "gitlab-ce" do
  action :install
end



#remote_file "wait AdminServer startup" do
#    path "/tmp/testfile"
#    source "#{node['gitlab']['external_url']}"
#    retries 60
#    retry_delay 10
#    backup false
#end


template '/etc/gitlab/gitlab.rb' do
  source '/gitlab.rb.erb'
  mode '0600'
  owner 'root'
  group 'root'
  variables({
    external_url: "#{node['gitlab']['external_url']}",
  })
  notifies :configure, 'simple_gitlab_configure[gitlab]', :immediately
end

#  do nothing by default, should be callsed by template '/etc/gitlab/gitlab.rb'
simple_gitlab_configure 'gitlab' do
  action :nothing
end



# Workaround to wait while GitLab is up
remote_file "wait AdminServer startup" do
  path "/tmp/testfile"
  source "#{node['gitlab']['external_url']}"
  retries 60
  retry_delay 10
  backup false
end

simple_gitlab_root_password 'gitlab_root_password' do
  root_password "#{node['gitlab']['root_password']}"
  action :set
end


node['gitlab']['groups'].each do |gitlab_group|
  simple_gitlab_group  gitlab_group  do
    group_name        gitlab_group
    group_path        gitlab_group
    root_username     'root'
    root_password     "#{node['gitlab']['root_password']}"
    base_gitlab_url   "#{node['gitlab']['external_url']}"
    action          :create
  end
end




node['gitlab']['projects'].each do |gitlab_project|
  simple_gitlab_project gitlab_project do
    owner             'cicd'
    root_username     'root'
    root_password     "#{node['gitlab']['root_password']}"
    base_gitlab_url   "#{node['gitlab']['external_url']}"
    action          :create
  end
end


users_list = []
node[:gitlab][:users].each do |current_user|
  Chef::Log.info(" --- #{current_user}")

  current_user.each do |user_id,user_details|
    users_list.push(user_id)
    Chef::Log.info(" --- #{user_id}")
    Chef::Log.info(" --- #{user_details}")
    Chef::Log.info(" --- #{users_list}")


    simple_gitlab_user user_id  do
      username        user_id
      password        user_details['password']
      name_of_user    user_details['name']
      email           user_details['email'] 
      root_username   'root'
      root_password   "#{node['gitlab']['root_password']}"
      base_gitlab_url "#{node['gitlab']['external_url']}"
      ssh_key_title   user_details['public_key']['key_title']
      ssh_key         user_details['public_key']['key']
      action          :create
    end
  end
end

simple_gitlab_manage_groups 'groups' do
  users             users_list
  groups            node['gitlab']['groups']
  access_level      50
  root_username     'root'
  root_password     "#{node['gitlab']['root_password']}"
  base_gitlab_url   "#{node['gitlab']['external_url']}"
  action          :add_users_to_groups
end







gem_package 'gitlab' do
  action :install
end



directory '/root/.ssh' do
  owner 'root'
  group 'root'
  mode '0600'
  action :create
end

template '/root/.ssh/id_rsa' do
#  content "#{node['gitlab']['jenkins_private_key']}"
  source '/id_rsa.erb'
  mode '0600'
  owner 'root'
  group 'root'
  variables({
    private_key: "#{node['gitlab']['jenkins_private_key']}",
  })

end


template '/tmp/clone_repo_to_new_server.sh' do
  source '/copy_to_local_repo.sh.erb'
  mode '0755'
  owner 'root'
  group 'root'
  variables({
    git_ip: "#{node['ipaddress']}",
  })
end


template '/root/.ssh/config' do
  source '/config.erb'
  mode '0600'
  owner 'root'
  group 'root'
  variables({
    git_ip: "#{node['ipaddress']}",
  })
end




directory '/tmp/jobs_to_add' do
  owner 'root'
  group 'root'
  mode '0600'
  action :create
end

jobs_to_be_added.each do |job_to_add|
    template "jobs_to_add/#{job_to_add}" do
      source "job/#{job_to_add}"
      mode '0600'
      owner 'root'
      group 'root'
  end
end

execute 'copy_repo' do
  command '/tmp/clone_repo_to_new_server.sh'
end
