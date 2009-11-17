require 'securerandom'

module Messager
  class DupricateUser < Exception;end
  class UserNotFound < Exception;end
  class User < Sequel::Model
    set_schema do
      primary_key :id
      String :name, :unique => true, :null => false
      String :password
      String :random_key, :unique => true
    end
    one_to_many :channels
    one_to_many :sessions do |ds|
      ds.filter('expire_at > ?', Time.now)
    end
    create_table unless table_exists?

    def all_sessions
      Session.filter('user_id = ?', self.id).all
    end

    def before_create
      self.random_key = SecureRandom.hex(32)
    end

    def create_session(channel = nil) # XXX: channel should String
      if channel
        channel = Channel.find_or_create(:name => channel)
      end
      Session.create(:user => self, :channel => channel)
    end
  end
end
