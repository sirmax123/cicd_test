log 'message' do
  message "#{node}"
  level :info
end


log 'message' do
  message "======123======="
  level :info
end



log 'message' do
  message "#{node['database_host']}"
  level :info
end


template '/tmp/data-access.properties' do
  source '/data-access.properties.erb'
  mode '0440'
  owner 'root'
  group 'root'
  variables({
    mysql_pass: "#{node['database_creds']['password']}",
    mysql_user: "#{node['database_creds']['username']}",
    mysql_db:   "#{node['database_creds']['name']}",
    mysql_host: "#{node['database_host']}"
  })
end