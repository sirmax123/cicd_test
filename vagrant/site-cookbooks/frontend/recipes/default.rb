log 'message' do
  message "#{node['frontend']}"
  level :info
end




node[:frontend][:apache_modules].each do |mod|
    apache_module "#{mod}" do
      enable
    end
end

log 'message' do
  message "#{node['frontend']['backends']}"
  level :info
end

web_app "petclininc" do
    template 'petclinic.conf.erb'
    server_name 'petclinic'
    backends node[:frontend][:backends]
end


log 'message' do
  message "#{node['frontend']['backends']}"
  level :info
end

