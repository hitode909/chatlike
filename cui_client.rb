# -*- coding: utf-8 -*-
require "net/http"
require "uri"
require "pp"
require "json"
require 'open-uri'

res = Net::HTTP.post_form(URI.parse('http://localhost:7000/api/session/login'),
  {:name => ARGV.shift, :password => ARGV.shift})
session = JSON.parse res.body
pp session

puts "http://localhost:7000/api/session/get?session=#{session['session']['random_key']}"
loop do
  message = JSON.parse open("http://localhost:7000/api/session/get?session=#{session['session']['random_key']}&timeout=60").read
  pp message
end
