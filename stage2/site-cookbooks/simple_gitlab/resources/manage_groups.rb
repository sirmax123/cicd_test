property :groups, Array, default: nil
property :users, Array, default: nil
property :access_level, Integer, default: nil


property :root_username, String, default: 'root'
property :root_password, String, default: 'root'
property :base_gitlab_url, String, default: 'http://127.0.0.1/'



require 'net/http'
require 'json'
require 'uri'




def add_users_to_groups()
  groups.each do |group|
    users.each do |user|
      res = add_user_to_group(user, group)
        puts("Add user: " + user.to_s + " to group " + group.to_s + "=>> " + JSON.parse(res.body).to_s)
    end
  end
end


def add_user_to_group(user, group)
  group_id = find_id_by_name(group, 'group')
  user_id  = find_id_by_name(user, 'user')
  puts("user_id = " + user_id.to_s + " group_id = " + group_id.to_s)
  return add_user_to_group_by_id(user_id, group_id)
end


def find_id_by_name(object_name, type)
  if type == 'user'
    url = base_gitlab_url + '/api/v3/users/'
    field_to_check = 'username'
  elsif type == 'group'
    url = base_gitlab_url + $groups_url
    field_to_check = 'name'
  else
    return nil
  end
   
  res = get_request(url, $headers)
  puts(JSON.parse(res.body))
  JSON.parse(res.body).each do |cur_object|
    puts("---------")
    puts(cur_object["#{field_to_check}"])
    puts(object_name)
    puts("---------")
    if cur_object["#{field_to_check}"].to_s == object_name.to_s
      puts("Found id = " + cur_object['id'].to_s + "   for " + object_name.to_s + " type = " + type.to_s )
      return cur_object['id']
    end
  end
  return nil 
end

def add_user_to_group_by_id(user_id, group_id)
  puts("user_id = " + user_id.to_s + " group_id =  " + group_id.to_s)

  url = base_gitlab_url + '/api/v3/groups/' + group_id.to_s + '/members'
  data = {
    :access_level => access_level,
    :user_id      => user_id
  }

  res = post_request(url, data, $headers)
  return res
end

action :add_users_to_groups do
  puts("action: Add users to groups")
  
  $groups_url = '/api/v3/groups/'

  $headers = {
    'PRIVATE-TOKEN' => get_token(),
    'Content-Type'  => 'application/json'
  }

  result = add_users_to_groups()
  puts(result)


  find_id_by_name('user1', 'user')

end

action :delete_users_from_groups do
    puts("action delete_users_from_groups is not implemented yet")
end


