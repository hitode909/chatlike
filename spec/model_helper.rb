# -*- coding: utf-8 -*-
require 'model/init'
require 'fixture_dependencies'
require 'fixture_dependencies/rspec/sequel'
FixtureDependencies.fixture_path = File.dirname(__FILE__) + '/fixtures'

# # XXX: ロードしてないとhas_manyのカウントが変になったりする……
# ["messager/channel","messager/session","messager/user"].each {|s|
#   FixtureDependencies.load s
# }
