log 'message' do
  message "#{node}"
  level :info
end


#remote_file '/var/www/customers/public_html/index.php' do
#  source 'http://somesite.com/index.php'
#  action :create
#end


#[gitlab_gitlab-ce]
#name=gitlab_gitlab-ce
#baseurl=https://packages.gitlab.com/gitlab/gitlab-ce/el/6/$basearch
#repo_gpgcheck=1
#gpgcheck=0
#enabled=1
#gpgkey=https://packages.gitlab.com/gitlab/gitlab-ce/gpgkey
#sslverify=1
#sslcacert=/etc/pki/tls/certs/ca-bundle.crt
#metadata_expire=300

#[gitlab_gitlab-ce-source]
#name=gitlab_gitlab-ce-source
#baseurl=https://packages.gitlab.com/gitlab/gitlab-ce/el/6/SRPMS
#repo_gpgcheck=1
#gpgcheck=0
#enabled=1
#gpgkey=https://packages.gitlab.com/gitlab/gitlab-ce/gpgkey
#sslverify=1
#sslcacert=/etc/pki/tls/certs/ca-bundle.crt
#metadata_expire=300


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