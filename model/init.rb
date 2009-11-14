# -*- coding: utf-8 -*-
require 'sequel'

DB_ENV rescue  DB_ENV = 'app'
Sequel::Model.plugin(:schema)
DB = Sequel.sqlite(DB_ENV == 'test' ? 'test.db' : 'app.db')

require 'model/messager'
require 'model/user'
require 'model/session'
require 'model/channel'
require 'model/message'
