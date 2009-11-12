require 'digest/sha1'
require 'securerandom'

module MessageQueue
  def self.register name, password
  end

  def self.login user, password
  end

  class User < Sequel::Model
    set_schema do
      primary_key :id
      String :name, :unique => true, :null => false
      String :password
      String :random_key, :unique => true
    end
    one_to_many :channels
    one_to_many :sessions
    create_table unless table_exists?

    def before_create
      self.random_key = SecureRandom.hex(32)
    end
  end

  class Channel < Sequel::Model
    set_schema do
      primary_key :id
      String :name, :unique => true
    end
    one_to_many :sessions
    create_table unless table_exists?

    def users
      sessions.map(&:user).uniq
    end
  end

  class Session < Sequel::Model
    set_schema do
      primary_key :id
      String :random_key, :unique => true
      foreign_key :user_id, :null => false
      foreign_key :channel_id
      time :created_at
      time :modified_at
    end
    many_to_one :user
    many_to_one :channel
    create_table unless table_exists?

    def before_create
      self.created_at = Time.now
      self.random_key = SecureRandom.hex(32)
    end

    def before_save
      self.modified_at = Time.now
    end
  end
end
