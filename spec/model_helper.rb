# -*- coding: utf-8 -*-
require 'model/init'
require 'fixture_dependencies'
require 'fixture_dependencies/rspec/sequel'
FixtureDependencies.fixture_path = File.dirname(__FILE__) + '/fixtures'

# # XXX: ロードしてないとhas_manyのカウントが変になったりする……
# ["session_manager/channel","session_manager/session","session_manager/user"].each {|s|
#   FixtureDependencies.load s
# }
