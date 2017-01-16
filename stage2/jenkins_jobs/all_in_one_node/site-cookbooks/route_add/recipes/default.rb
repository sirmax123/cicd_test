route '10.0.1.0/24' do
  gateway '10.0.10.1'
end

directory '/root/.ssh' do
  owner 'root'
  group 'root'
  mode '0400'
  action :create
end

puts("#{node[:jenkins_slave_public_key]}")
file '/root/.ssh/authorized_keys' do
  content "#{node[:jenkins_slave_public_key]}"
  mode '0644'
  owner 'root'
  group 'root'
end

