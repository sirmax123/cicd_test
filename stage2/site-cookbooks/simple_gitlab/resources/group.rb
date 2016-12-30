property :group_name, String, default: nil
property :group_path, String, default: nil
property :description, String, default: nil 
property :visibility_level, String, default: 0 #"The group's visibility. 0 for private, 10 for internal, 20 for public."
#property :lfs_enabled 
#property :request_access_enabled


property :root_username, String, default: 'root'
property :root_password, String, default: 'root'
property :base_gitlab_url, String, default: 'http://127.0.0.1/'



require 'net/http'
require 'json'
require 'uri'




def search_group()
  url = base_gitlab_url + '/api/v3/users/'
  res = get_request(url, $headers)

  match_users = []

  JSON.parse(res.body).each do |user|
    if user['username'] == username or user['email'] == email
      match_users.push(user)
    end
  end 
  return match_users
end


def update_group()
   # not implemented
end


def create_group()

  url = base_gitlab_url + $groups_url

  data = {
    :name => group_name,
    :path => group_path,
    :visibility_level => visibility_level
  }
  if not description.nil?
    data['description'] = description
  end 
  
  res = post_request(url, data, $headers)
  response_data = JSON.parse(res.body)
  puts(response_data)
  # Groups update is not implemented

  return response_data
end




action :create do

  # a mix of built-in Chef resources and Ruby
  puts("action create")
  
  $groups_url = '/api/v3/groups/'

  $headers = {
    'PRIVATE-TOKEN' => get_token(),
    'Content-Type'  => 'application/json'
  }


  create_group_result = create_group()
  puts(create_group_result)
end

action :delete do
    # a mix of built-in Chef resources and Ruby
    puts("action delete is not implemented yet")
end


