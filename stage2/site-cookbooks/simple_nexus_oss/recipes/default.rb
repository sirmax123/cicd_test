## very basic!!!! will remove hardcode/shell if I'll have time

Chef::Log.info(" --- NEXUS_OSS ---")


user 'nexus' do
  comment 'Nexus OSS User'
  home '/usr/local/nexus'
  shell '/bin/bash'
end


directory '/usr/local/nexus' do
  owner 'nexus'
  group 'nexus'
  mode '0755'
  action :create
end

remote_file "Download_Nexus" do
    path "/usr/local/nexus/nexus-2.13.0-01-bundle.tar.gz"
    source "https://sonatype-download.global.ssl.fastly.net/nexus/oss/nexus-2.13.0-01-bundle.tar.gz"
    retries 60
    retry_delay 10
    backup false
    checksum "4c4e88a2410e1740e688ea1ab3c6066a6a90f76c479e10e4718c517a27f3a614"
end

bash 'install' do
  cwd '/usr/local/nexus'
  code <<-EOF
    tar -xvf nexus-2.13.0-01-bundle.tar.gz
  EOF
  not_if { ::File.exist?('/usr/local/nexus/nexus-2.13.0-01') }
end

template '/etc/init.d/nexus' do
  source '/nexus.erb'
  mode '0755'
  owner 'root'
  group 'root'
#  variables({
#    external_url: "#{node['gitlab']['external_url']}",
#  })
end

Chef::Log.info("=======")
Dir.glob("/usr/local/nexus/**/*/").each do |path|
  file path do
    owner "nexus"
    group "nexus"
  end if File.file?(path)  
  directory path do
    recursive true
    owner "nexus"
    group "nexus"
    mode  "0755"
  end if File.directory?(path)

end

Dir.glob("/usr/local/nexus/**/*").each do |path|
  file path do
    owner "nexus"
    group "nexus"
  end if File.file?(path)  
  directory path do
    recursive true
    owner "nexus"
    group "nexus"
    mode  "0755"
  end if File.directory?(path)

end

Chef::Log.info("=======")


service "nexus" do
  action [:start, :enable]
end


remote_file "WaitForNexuss" do
    path "/tmp/nexus_up"
    source "http://127.0.0.1:8081/nexus"
    retries 60
    retry_delay 10
    backup false
end

simple_nexus_oss_repo 'test-repo6' do
  action :create
end


#simple_gitlab_manage_groups 'groups' do
#  users             users_list
#  groups            node['gitlab']['groups']
#  access_level      50
#  root_username     'root'
#  root_password     "#{node['gitlab']['root_password']}"
#  base_gitlab_url   "#{node['gitlab']['external_url']}"
#  action          :add_users_to_groups
#end



