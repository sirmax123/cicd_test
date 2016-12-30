def test_helper
  puts("TestHelper")
end


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

