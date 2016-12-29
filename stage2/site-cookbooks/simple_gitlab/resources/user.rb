property :password, String, default: 'password'
property :username, String, default: 'user'
property :email, String, default: 'EMAIL@DOMAIN.TLD'
property :name_of_user, String, default: 'Vasya Pupkin'
property :ssh_key, String, default: nil
property :ssh_key_title, String, default: nil


property :root_username, String, default: 'root'
property :root_password, String, default: 'root'
property :base_gitlab_url, String, default: 'http://127.0.0.1/'



require 'net/http'
require 'json'
require 'uri'


def get_token()
  session_url = '/api/v3/session/'

  params = { :login => root_username, :password => root_password }
  uri = URI(base_gitlab_url + session_url)
  res = Net::HTTP.post_form(uri, params)
  
  response_data = JSON.parse(res.body)
  return response_data['private_token']
end

def post_request(url, data, headers)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri, headers)
  request.body = data.to_json
  return http.request(request)
end

def put_request(url, data, headers)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Put.new(uri.request_uri, headers)
  request.body = data.to_json
  return http.request(request)
end


def get_request(url, headers)
  uri = URI.parse(url)
  
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri, $headers)

  http.request(request)
  return http.request(request)
end



def search_user()
  url = base_gitlab_url + '/api/v3/users/'
  res = get_request(url, $headers)

  match_users = []

  JSON.parse(res.body).each do |user|
#    puts(user)
#    puts(user['username'])
#    puts("-------")
    if user['username'] == username or user['email'] == email
      match_users.push(user)
    end
  end 
  return match_users
end


def update_user()
  update_results = []
  users_to_update = search_user()
  users_to_update.each do |user|    
    url = base_gitlab_url + $users_url + user['id'].to_s

    data = {
      :email    => email,
      :password => password,
      :username => username,
      :name     => name_of_user,
    }
    res = put_request(url, data, $headers)
    update_results.push(JSON.parse(res.body))
    puts(add_ssh_key(user['id'], ssh_key, ssh_key_title))

  end
  return update_results
end


def add_ssh_key(id, key, title)

  if (not key.nil?) and (not title.nil?) and (not id.nil? )
    puts "=================="
    puts "add key"
    puts id
    puts title
    puts key
    puts "=================="
    keys_url = '/api/v3/users/'
    url = base_gitlab_url + keys_url + id.to_s + '/keys/'

    data = {
      :title => title,
      :key   => ssh_key
    }
    res = post_request(url, data, $headers)
    return res
  else
    return nil
  end
end


def create_user()
  url = base_gitlab_url + $users_url

  data = {
    :email    => email,
    :password => password,
    :username => username,
    :name     => name_of_user,
  }
  
  res = post_request(url, data, $headers)
  response_data = JSON.parse(res.body)
  puts "SSH"
  puts response_data
  # 
  puts(add_ssh_key(response_data['id'], ssh_key, ssh_key_title))
  puts "SSH"

  if res.code.to_i == 409
    puts('Looks like user exists, updating ...')
    return update_user()
  else
    puts "SSH"
    puts response_data
    # 
    puts(add_ssh_key(response_data['id'], ssh_key, ssh_key_title))
    puts "SSH"
    return response_data
  end

  
end




action :create do
  # a mix of built-in Chef resources and Ruby
  puts("action create")
  
  $users_url = '/api/v3/users/'

  $headers = {
    'PRIVATE-TOKEN' => get_token(),
    'Content-Type'  => 'application/json'
  }


  create_user_result = create_user()
  puts(create_user_result)
end

action :delete do
    # a mix of built-in Chef resources and Ruby
    puts("action delete is not implemented yet")
end


