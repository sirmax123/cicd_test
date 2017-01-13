property :name,            String
property :user_first_name, String, default: 'DefaultUserFirstName'
property :user_last_name,  String, default: 'DefaultUserLastName'
property :user_email,      String, default: 'user@domain.tld'
property :user_roles,      Array, default:  ['test-role', 'repo-all-full', 'repository-any-read']
property :user_password,   String
property :user_status,     String, default: 'active'

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

  roles_xml =  format_roles_to_xml(user_roles)
  create_user_result = create_user(name,
                                   user_email,
                                   user_status,
                                   user_first_name,
                                   user_last_name,
                                   user_password,
                                   roles_xml,
                                   root_username,
                                   root_password,
                                   endpoint
                                  )

  puts(create_user_result)
end


action :delete do
   puts("action delete is not implemented yet")
end

