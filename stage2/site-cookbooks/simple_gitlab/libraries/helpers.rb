def test_helper
  puts("TestHelper")
end


def try_to_get_token()
  session_url = '/api/v3/session/'

  params = { :login => root_username, :password => root_password }
  begin
    uri = URI(base_gitlab_url + session_url)
    res = Net::HTTP.post_form(uri, params)
  
    response_data = JSON.parse(res.body)
    puts(response_data)
    return response_data['private_token']
  rescue StandartError => e
    puts(e)
    puts(e.backtrace.inspect)
    return nil
  end
end


def get_token()
  try_count = 10
  sleep_time = 30

  while try_count > 0
    puts("Try to get token... attempt " + try_count.to_s())
    token = try_to_get_token
    unless  token.nil?
      return token
    end  
    try_count = try_count - 1 
    puts("Failed to get token ... will re-try in " + sleep_time.to_s() + " seconds")
    sleep sleep_time
  end
end


def post_request(url, data, headers)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri, headers)
  request.body = data.to_json
  puts("sending request")
  res = http.request(request)
  puts(res)
  return res
end

def put_request(url, data, headers)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Put.new(uri.request_uri, headers)
  request.body = data.to_json
  puts("sending request")
  res = http.request(request)
  puts(res)
  return res 
end


def get_request(url, headers)
  uri = URI.parse(url)
  
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri, $headers)

  http.request(request)
  puts("sending request")
  res = http.request(request)
  puts(res)
  return res 
end

