# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'json'

def delete_test_db
  SessionManager::Session.delete
  SessionManager::User.delete
  SessionManager::Message.delete
  SessionManager::Channel.delete
end

def json(str)
  JSON.load(str)
end

DB_ENV = 'test'
