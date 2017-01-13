#!/opt/chef/embedded/bin/ruby

require 'net/http'
require 'nokogiri'


def post_xml(url_string, xml_string, root_username, root_password)
  uri = URI.parse url_string
  request = Net::HTTP::Post.new(uri.path)
  request.add_field("Accept", "application/xml")
  request.add_field("Content-Type", "application/xml")
  request.basic_auth root_username, root_password
  request.body = xml_string
  # Do I really need this? FixMe!
  request.content_type = 'application/xml'
  response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
  response.body
end


def get_xml(url_string, root_username, root_password)
  uri = URI.parse url_string
  request = Net::HTTP::Get.new(uri.path)
  request.add_field("Accept", "application/xml")
  request.add_field("Content-Type", "application/xml")
  request.basic_auth root_username, root_password
  # Do I really need this? FixMe!
  request.content_type = 'application/xml'
  response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
  response.body  
end

def create_repo(repo_name, repo_id, exposed, indexable, repoPolicy, browseable, repo_format ,repo_provider ,repoType, root_username, root_password, endpoint)
#  hardcoded path
  repositories_endpoint = 'repositories'
# hardcoded repo template  
  repo_template  = "
<repository>
<data>
    <id>#{repo_id}</id>
    <name>#{repo_name}</name>
    <provider>#{repo_provider}</provider>
    <providerRole>org.sonatype.nexus.proxy.repository.Repository</providerRole>
    <format>#{repo_format}</format>
    <repoType>#{repoType}</repoType>
    <exposed>#{exposed}</exposed>
    <writePolicy>ALLOW_WRITE_ONCE</writePolicy>
    <browseable>#{browseable}</browseable>
    <indexable>#{indexable}</indexable>
    <notFoundCacheTTL>0</notFoundCacheTTL>
    <repoPolicy>#{repoPolicy}</repoPolicy>
    <downloadRemoteIndexes>false</downloadRemoteIndexes>
   </data>
</repository>
"
puts(repo_template)
result = post_xml(endpoint + repositories_endpoint, repo_template, root_username, root_password)
return result
end


#'Artifact Download'
#'Artifact Upload'


def create_role(role_name, role_id, role_description, privileges_string, root_username, root_password, endpoint)
  roles_endpoint = "roles"
  role_template = "
<role-request>
  <data>
    <id>#{role_id}</id>
    <name>#{role_name}</name>
    <sessionTimeout>0</sessionTimeout>
    <roles>
      <role>ui-basic</role>
      <role>ui-repo-browser</role>
    </roles>
    <privileges>
      <privilege>repository-test-repo4</privilege>
       #{privileges_string}
    </privileges>
    <userManaged>true</userManaged>
  </data>
</role-request>
"
puts(role_template)
result = post_xml(endpoint + roles_endpoint, role_template, root_username, root_password)
return result
end


def get_privileges_ids_by_names(priv_name_list, root_username, root_password, endpoint)

  privs_endpoint = "privileges"

  priv_id_list = []
  result = get_xml(endpoint + privs_endpoint, root_username, root_password)
  docXML = Nokogiri::XML(result)
  
  #puts(docXML)

  priv_name_list.map! { |item| item = "name='" + item.to_s + "'" }
  search_string = priv_name_list.join(' or ')
  privilege_items = docXML.xpath("/privilege-list-response/data/privilege-item[#{search_string}]")
  

  privilege_items.each do |privilege_item|
    #puts(privilege_item)
    id = privilege_item.at('id').text
    priv_id_list.push(id)
  end
  return priv_id_list
end

def format_privileges_id_to_xml(privileges_ids)
  xml = ""
  privileges_ids.map! { |item| item = "<privilege>" + item.to_s + "</privilege>" }
  xml = privileges_ids.join("\n")
  return xml
end



def create_user(user_id, user_email, user_status='active', 
                user_first_name, user_last_name, user_password, role_list_xml,
                root_username, root_password, endpoint
                )

  users_endpoint = "users"

  user_template = "
<user-request>
  <data>
        <userId>#{user_id}</userId>
        <email>#{user_email}</email>
        <status>#{user_status}</status>
        <firstName>#{user_first_name}</firstName>
        <roles>
          #{role_list_xml}
        </roles>
        <lastName>#{user_last_name}</lastName>
        <password>#{user_password}</password>
  </data>
</user-request>
"
#<role>repo-all-full</role>
#<role>repo-all-full</role>

  puts(user_template)
  result = post_xml(endpoint + users_endpoint, user_template, root_username, root_password)
  return result
end

def format_roles_to_xml(roles_list)
  xml = ""
  roles_list.map! { |item| item = "<role>" + item.to_s + "</role>" }
  xml = roles_list.join("\n")
  return xml
end


#a = get_privileges_ids_by_names(['Artifact Download', 'Artifact Upload'], 'admin', 'admin123', 'http://127.0.0.1:8081/nexus/service/local/')


#puts(a)
#b= format_privileges_id_to_xml(a)
#puts(b)

#r = create_role('test-role', 'test-role', 'role-description', b, 'admin', 'admin123', 'http://127.0.0.1:8081/nexus/service/local/')
#puts(r)

#c = format_roles_to_xml(['test-role', 'repo-all-full', 'repository-any-read'])
#puts(c)

#d = create_user(user_id='sirmax', 
#                user_email='sirmax123@gmail.com', 
#                user_first_name='Max', 
#                user_last_name='Mazur',
#                user_password='sirmax123',
#                role_list_xml=format_roles_to_xml(['test-role', 'repo-all-full', 'repository-any-read']),
#                root_username='admin',
#                root_password='admin123',
#                endpoint='http://127.0.0.1:8081/nexus/service/local/'
#                )
#puts(d)

# exaple how to edit XML
#doc = Nokogiri::XML(repo_template)
# puts(doc)
#puts(doc.at_xpath("//id"))
#puts('------')
#puts(doc.at_xpath("//id").content)

#doc.at_xpath("//id").content = new_repo_id 
#doc.at_xpath("//name").content = new_repo_name







