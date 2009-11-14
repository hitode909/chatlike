# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'json'

def delete_test_db
  Messager::Session.delete
  Messager::User.delete
  Messager::Message.delete
  Messager::Channel.delete
end

def json(str)
  JSON.load(str)
end

DB_ENV = 'test'
