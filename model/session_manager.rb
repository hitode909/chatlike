require 'model/session_manager/user'
require 'model/session_manager/session'
require 'model/session_manager/channel'
require 'model/session_manager/message'

module SessionManager
  class << self
    def register name, password, channel = nil
      begin
        u = User.create(:name => name, :password => password)
      rescue(Sequel::DatabaseError) => e
        raise DupricateUser
      end
      u.create_session channel
    end

    def login name, password, channel = nil
      u = User.find(:name => name, :password => password)
      raise UserNotFound unless u
      u.create_session(channel)
    end

    def logout key
      Session.find(:random_key => key).kill
    end

    def session key
      Session.find({:random_key => key} & (:expire_at > Time.now))
    end

    def user key
      User.find(:random_key => key)
    end

    def get
    end

    def post
    end
  end
end
