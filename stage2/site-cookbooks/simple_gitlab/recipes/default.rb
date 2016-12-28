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

simple_gitlab_cli 'gitlab' do
  root_password 'r00tme123'
  action :configure
end



gem_package 'gitlab' do
   action :install
end