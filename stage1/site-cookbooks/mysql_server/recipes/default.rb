mysql_service 'mysql' do
#  version '5.7'
  bind_address          "#{node[:mysql_server][:bind_address]}"
  port                  "#{node[:mysql_server][:bind_password]}"
  data_dir              "#{node[:mysql_server][:data_dir]}"
  initial_root_password "#{node[:mysql_server][:root_password]}"
  action [:create, :start]
end
