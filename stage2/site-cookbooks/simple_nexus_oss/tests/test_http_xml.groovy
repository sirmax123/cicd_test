#!/opt/chef/embedded/bin/ruby


require 'net/http'
require 'nokogiri'

api_endpoint = 'http://127.0.0.1:8081/nexus/service/local/'
repositories_endpoint = 'repositories'


new_repo_name = 'test-repo5'
new_repo_id = 'test-repo5'


exposed = true
indexable = true
repoPolicy = "RELEASE"
browseable = true
format = "maven2"
provider = "maven2"
repoType = "hosted"


repo_template  = "
<data>
    <id>#{new_repo_id}</id>
    <name>#{new_repo_name}</name>
    <provider>maven2</provider>
    <providerRole>org.sonatype.nexus.proxy.repository.Repository</providerRole>
    <format>#{format}</format>
    <repoType>#{hosted}</repoType>
    <exposed>#{exposed}</exposed>
    <writePolicy>ALLOW_WRITE_ONCE</writePolicy>
    <browseable>#{browseable}</browseable>
    <indexable>#{indexable}</indexable>
    <notFoundCacheTTL>0</notFoundCacheTTL>
    <repoPolicy>#{repoPolicy}</repoPolicy>
    <downloadRemoteIndexes>false</downloadRemoteIndexes>
    <defaultLocalStorageUrl>file:/usr/local/nexus/sonatype-work/nexus/storage/test-repo4/</defaultLocalStorageUrl>
   </data>
</repository>
"



#puts(repo)

#doc = Nokogiri::XML(repo_template)
# puts(doc)
#puts(doc.at_xpath("//id"))
#puts('------')
#puts(doc.at_xpath("//id").content)

#doc.at_xpath("//id").content = new_repo_id 
#doc.at_xpath("//name").content = new_repo_name





#def post_xml(url_string, xml_string)
#  uri = URI.parse url_string
#  request = Net::HTTP::Post.new(uri.path)
#  request.add_field("Accept", "application/xml")
#  request.add_field("Content-Type", "application/xml")
#  request.basic_auth 'admin', 'admin123'
#  request.body = xml_string
#  request.content_type = 'application/xml'
#  response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
#  response.body
#end

def create_repo(repo_name)



end


# a = post_xml(api_endpoint + repositories_endpoint, repo)
# puts(a)