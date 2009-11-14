# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'json'

def delete_test_db
  db = File.dirname(__FILE__) + '/../test.db'
  if File.exist?(db)
    File.delete(db)
  end
end

def json(str)
  JSON.load(str)
end

DB_ENV = 'test'
delete_test_db
