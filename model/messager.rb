require 'digest/sha1'

module Messager
  class << self
    def register name, password
      begin
        u = User.create(:name => name, :password => password)
      rescue(Sequel::DatabaseError) => e
        raise DupricateUser
      end
      u.create_session
    end

    def login name, password
      u = User.find(:name => name, :password => password)
      raise UserNotFound unless u
      u.create_session
    end

    def logout key
      Session.find(:random_key => key).kill
    end

    def session key
      Session.find(:random_key => key, :is_alive => true)
    end

    def get
    end

    def post
    end
  end
end
