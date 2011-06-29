#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'net/http'
require 'net/https'

instance = 'http://master-1:3000'
username = 'puppet'
password = 'password'

url = URI.parse(instance)

def token(http, url)
  req_token = Net::HTTP::Get.new(url.path + '/nodes/new')
  get_token = http.request(req_token)
  noko_doc = Nokogiri::HTML(get_token.body)
  auth_token = noko_doc.xpath('//input[@name="authenticity_token"]').first['value']
end

connection = Net::HTTP.new(url.host, url.port)
connection.use_ssl = true if url.scheme == 'https'

connection.start do |http|

  token_data = token(http, url)

  data = {"node"=>{"name"=>"foo.puppetlabs.com", "node_class_ids"=>[""], "parameter_attributes"=>[{ "value"=>"", "key"=>"" }], "node_group_ids"=>[""], "description"=>""}, "authenticity_token"=>token_data}

  add_req = Net::HTTP::Post.new(url.path + '/nodes')
  add_req.set_form_data(data)
  http.request(add_req)
end
