property :name,          String
property :repo_id,       String, default: ''
property :exposed,       String, default: true
property :indexable,     String, default: 'true'
property :repoPolicy,    String, default: 'RELEASE'
property :browseable,    String, default: 'true'
property :repo_format,   String, default: 'maven2'
property :repo_provider, String, default: 'maven2'
property :repoType,      String, default: 'hosted'



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

  unless (defined? repo_id)
    puts('==========')
    repo_id = name
    puts(repo_id)
  end

  if repo_id.nil?
    puts('==========')
    repo_id = name
    puts(repo_id)
  end


  if repo_id.length == 0
    puts('==========')
    repo_id = name
    puts(repo_id)
  end

  puts(repo_id)
  create_repo_result = create_repo(name,
                                   repo_id,
                                   exposed,
                                   indexable,
                                   repoPolicy,
                                   browseable,
                                   repo_format,
                                   repo_provider,
                                   repoType,
                                   root_username,
                                   root_password,
                                   endpoint
                                   )
  puts(create_repo_result)

puts(name)

end
#
action :delete do
   puts("action delete is not implemented yet")
end

