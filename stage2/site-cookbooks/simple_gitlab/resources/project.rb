property :owner,        String

property :root_username,   String, default: 'root'
property :root_password,   String, default: 'root'
property :base_gitlab_url, String, default: 'http://127.0.0.1/'



require 'net/http'
require 'json'
require 'uri'



def list_namespaces()
  url = base_gitlab_url + '/api/v3/namespaces'
  res = get_request(url, $headers)
  return JSON.parse(res.body)
end

def find_namespace_id_for_owner()
  namespaces = list_namespaces()

  namespaces.each  do |namespace|
    puts(namespace)
    url = base_gitlab_url + '/api/v3/groups?search=' + namespace['path'].to_s 
    res = get_request(url, $headers)
    puts("path=" + namespace['path'].to_s + '  reply=' + res.body.to_s)

    JSON.parse(res.body).each do |search_result|
      
      puts('--')
      puts(search_result)
      puts(search_result['name'])
      puts('------')
      if search_result['name'] == owner
        puts("owner found")
        return namespace['id']
      end
    end
    return nil
  end

  
end

def create_project()
  owner_namespace = find_namespace_id_for_owner()
  puts("========================================")
  puts(owner_namespace)

  data = {
    :name => name,
    :namespace_id =>owner_namespace
  }
  url = base_gitlab_url + '/api/v3/projects'

  res = post_request(url, data, $headers)
  response_data = JSON.parse(res.body)
  puts(response_data)
  
end




action :create do
  puts("action create")
  
  $headers = {
    'PRIVATE-TOKEN' => get_token(),
    'Content-Type'  => 'application/json'
  }


  project = create_project()
  puts(project)
end

action :delete do
    # a mix of built-in Chef resources and Ruby
    puts("action delete is not implemented yet")
end


