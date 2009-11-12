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

    one_to_many :sessions do |ds|
      ds.filter('is_alive = ?', true)
    end

    create_table unless table_exists?

    def users
      sessions.map(&:user).uniq
    end

    def all_sessions
      Session.filter('channel_id = ?', self.id).all
    end
  end

  class Session < Sequel::Model
    set_schema do
      primary_key :id
      String :random_key, :unique => true
      foreign_key :user_id, :null => false
      foreign_key :channel_id
      time :created_at
      time :expire_at
      TrueClass :is_alive, :default => true
    end
    many_to_one :user
    many_to_one :channel
    create_table unless table_exists?

    def before_create
      self.created_at = Time.now
      self.expire_at  = Time.now + self.expire_duration
      self.random_key = SecureRandom.hex(32)
    end

    def update_expire
      self.expire_at = Time.now + self.expire_duration
    end

    def expire_duration
      600
    end

    def check_alive
      self.still_alive or self.kill
    end

    def still_alive
      self.is_alive and self.expire_at > Time.now
    end

    def kill
      self.is_alive = false
      self.save
    end
  end
end
