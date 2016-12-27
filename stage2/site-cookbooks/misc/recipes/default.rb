log 'message' do
  message "#{node['misc']}"
    level :info
end

log 'message' do
  message "#{node['database_host']}"
    level :info
end

log 'message' do
  message "#{node['misc']}"
    level :info
end


node['misc'][:packages_to_install].each do |p|

  log 'message' do
    message "#{node}"
    level :info
  end

  package p do
    action    :install
  end
end
