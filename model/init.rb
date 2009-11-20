# -*- coding: utf-8 -*-
require 'sequel'

DB_ENV rescue  DB_ENV = 'app'
Sequel::Model.plugin(:schema)
if DB_ENV == 'test'
  DB = Sequel.sqlite('test.db')
else
  # create database chatlike character set utf8;
  DB = Sequel.mysql 'chatlike', :user => 'nobody', :password => 'nobody', :host => 'localhost', :encoding => 'utf8'
end

require 'model/messager'
require 'model/user'
require 'model/session'
require 'model/channel'
require 'model/message'
require 'model/vcs'
