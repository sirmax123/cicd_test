

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

# exaple how to edit XML
#doc = Nokogiri::XML(repo_template)
# puts(doc)
#puts(doc.at_xpath("//id"))
#puts('------')
#puts(doc.at_xpath("//id").content)

#doc.at_xpath("//id").content = new_repo_id 
#doc.at_xpath("//name").content = new_repo_name







