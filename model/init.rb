# -*- coding: utf-8 -*-
require 'sequel'

Sequel::Model.plugin(:schema)
DB = Sequel.sqlite('model.db')

require 'model/mq'

=begin
require "memcache"
requilre 'digest/sha1'

module Session
  def self.join(user, password)
    key = serialize(user, password)
    #return nil if client.get key
    client.set key, key, 10 * 60
    key
  end

  def self.login(user, password)
    client.get serialize(user, password)
  end

  def self.logout(user,password)
    client.delete(serialize(user, password)) == "DELETED\r\n"
  end

  def self.check(key)
    client.get key
  end

  private
  def self.serialize(user, password)
    Digest::SHA1.hexdigest(user + password + "key")
  end

  private
  def self.client
    MemCache.new('localhost:11211')
  end
end
=end
