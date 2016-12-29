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

log 'message' do
  message "#{node}"
  level :info
end


deps.each do |p|
  package p do
    action :install
  end
end

cookbook_file '/root/build_and_install_ruby_1_9_3.sh' do
  source 'build_and_install_ruby_1_9_3.sh'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end


execute 'build_ruby' do
  command '/root/build_and_install_ruby_1_9_3.sh'
end

template '/etc/gitlab/gitlab.rb' do
  source '/gitlab.rb.erb'
  mode '0600'
  owner 'root'
  group 'root'
  variables({
    external_url: "#{node['gitlab']['external_url']}",
  })
end




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

simple_gitlab_root_password 'gitlab_root_password' do
  root_password "#{node['gitlab']['root_password']}"
  action :set
end

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

#  do nithing by default, should be callsed by template '/etc/gitlab/gitlab.rb'
simple_gitlab_configure 'gitlab' do
  action :nothing
end


simple_gitlab_user 'testuser' do
  username        'testuser'
  password        'testpassword'
  name_of_user    'Ivan Ivanoff'
  email           'ivan@ivanoff.com' 
  root_username   'root'
  root_password   "#{node['gitlab']['root_password']}"
  base_gitlab_url "#{node['gitlab']['external_url']}"
  ssh_key_title   "mm"
  ssh_key         "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5EIrDnnxNBQavZcxiaHCzt0tjtfW0nNuFAz9f+fs4dL0/3wTbDCWO1l2tahTlupM8r/Tm4Sq20Gsrndl37zEFoqFZG42m1COuEMBgppl4er0cetlZV0qeKfcKQ0xXlZUE1LMJwQoBqAFl4QJ6g25PSPESJxd3wQ1RUfjvJ9kvW8c4sLHD0MjLAmX+VjFlbqNtM1l3uAIMc17RP4B2u4s2FqoyCjg9IxcGlL364FOWJZdHjFaBJvg1k4zo+WzSA2YtOgFxI0CWHUTIcjLD6d3np534zONNxjxsrUz5MBROPUQYOT9y3m9RDBXJVhdvk7V7lTzFYsrTrsJy+gu0pTCL root@mmaxur-pc"
  action          :create
end


simple_gitlab_user 'testuser1' do
  username        'testuser'
  password        'testpassword'
  name_of_user    'Ivan Petroff'
  email           'ivan@ivanoff.com' 
  root_username   'root'
  root_password   "#{node['gitlab']['root_password']}"
  base_gitlab_url "#{node['gitlab']['external_url']}"
  action          :create
end

simple_gitlab_user 'testuser2' do
  username        'testuser2'
  password        'testpassword'
  name_of_user    'Ivan Sidoroff'
  email           'ivan@sidoroff.com' 
  root_username   'root'
  root_password   "#{node['gitlab']['root_password']}"
  base_gitlab_url "#{node['gitlab']['external_url']}"
  action          :create
end



gem_package 'gitlab' do
  action :install
end

