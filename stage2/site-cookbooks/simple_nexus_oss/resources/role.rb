property :name,             String
property :role_id,          String, default: ''
property :role_description, String, default: 'RoleDescription'
property :privileges,      Array, default: ['Artifact Download', 'Artifact Upload']

# Admin creds
property :root_username, String, default: 'admin'
property :root_password, String, default: 'admin123'
property :endpoint,      String, default: 'http://127.0.0.1:8081/nexus/service/local/'
#
#

require 'net/http'
require 'json'
require 'uri'

action :create do

  unless (defined? role_id)
    role_id = name
    puts(role_id)
  end

  if (role_id.nil?)
    role_id = name
  end


  if (role_id.length == 0)
    role_id = name
  end

  puts("RoleName = " + name.to_s)
  puts("Role ID = " + role_id.to_s)
  puts("Endpoint = " + endpoint.to_s)
  privileges_string=get_privileges_ids_by_names(privileges, root_username, root_password, endpoint)

  puts("privileges_string=" + privileges_string.to_s)

  create_role_result = create_role(name,
                                   role_id,
                                   role_description,
                                   privileges_string,
                                   root_username,
                                   root_password,
                                   endpoint
                                   )
  puts(create_role_result)

end
#
action :delete do
   puts("action delete is not implemented yet")
end

