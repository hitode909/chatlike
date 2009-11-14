# -*- coding: utf-8 -*-
require 'sequel'

Sequel::Model.plugin(:schema)
DB = Sequel.sqlite('model.db')

require 'model/messager'
require 'model/user'
require 'model/session'
require 'model/channel'
require 'model/message'
