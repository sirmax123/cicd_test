#!/usr/bin/ruby

require 'net/http'
require 'json'


base_address = 'http://127.0.0.1/'
session_url = '/api/v3/session/'

params = { :login => 'root', :password => 'r00tme123' }


uri = URI(base_address + session_url)
res = Net::HTTP.post_form(uri, params)
puts res.to_hash['body']

response_data = JSON.parse(res.body)

puts response_data['private_token']


#curl -v  http://127.0.0.1/api/v3/session/ --data-urlencode 'login=root' --data-urlencode 'password=r00tme123'