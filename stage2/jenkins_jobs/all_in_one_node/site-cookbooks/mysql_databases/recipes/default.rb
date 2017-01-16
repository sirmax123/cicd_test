log 'message' do
     message "#{node}"
    level :info
end

connection = node['mysql_root_connection']
log 'message' do
  message "#{connection}"
  level :info
end

log 'message' do
  message "#{node['mysql_databases']}"
  level :info
end


#mysql2_chef_gem 'default' do
#    action :install
#end


mysql2_chef_gem 'default' do
  gem_version '0.3.17'
  action :install
end

node['mysql_databases'].each do |database, database_details|
#
  user = database_details['username']
  pass = database_details['password']
  database_name = database_details['name']
  hosts = database_details['allowed_hosts']
#
  log 'message' do
    message "#{database_name}"
    level :info
  end
#
  log 'message' do
    message "#{database_details}"
    level :info
  end
#
#

  mysql_database "#{database_name}" do
    connection connection
    action :create
  end
#
  hosts.each do |host|
    log 'message' do
        message "#{host}"
        level :info
    end
    mysql_database_user "#{user}"  do
      connection    connection
      password      pass
      database_name database_name
      host          host
      privileges    [:all]
      action        :grant
    end
  end
#
end
