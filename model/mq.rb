require 'digest/sha1'
require 'securerandom'

module MessageQueue

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

  class DupricateUser < Exception;end
  class UserNotFound < Exception;end
  class SessionNotFound < Exception;end

  class User < Sequel::Model
    set_schema do
      primary_key :id
      String :name, :unique => true, :null => false
      String :password
      String :random_key, :unique => true
    end
    one_to_many :channels
    one_to_many :sessions do |ds|
      ds.filter('is_alive = ?', true)
    end
    create_table unless table_exists?

    def all_sessions
      Session.filter('user_id = ?', self.id).all
    end

    def before_create
      self.random_key = SecureRandom.hex(32)
    end

    def create_session(channel = nil)
      if channel
        channel = Channel.find_or_create(:name => channel)
      end
      Session.create(:user => self, :channel => channel)
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
      Integer :last_fetched, :null => false, :default => 0
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

    def create_message(body, option = { })
      option.update(
        :body => body,
        :author => self.user,
        :author_session => self
      )
      Message.create(option)
    end

    def receive_message
      query = MessageQueue::Message.filter(:channel_id => self.channel_id, :receiver_id => self.user_id)
      query.or!(:channel_id => self.channel_id, :receiver_id => nil) if self.channel_id
      query.or!(:channel_id => nil, :receiver_id => nil)
      query.filter!((:id > self.last_fetched) & ~{:author_session_id => self.id}).order!(:id.asc)
      m = query.first
      if m
        self.last_fetched = m.id
      end
      m
    end

  end

  class Message < Sequel::Model
    set_schema do
      primary_key :id
      String :body, :null => false
      foreign_key :author_id, :null => false
      foreign_key :author_session_id, :null => false
      foreign_key :receiver_id
      foreign_key :channel_id
      time :created_at
    end
    many_to_one :author, :class => User
    many_to_one :author_session, :class => Session
    many_to_one :receiver, :class => User
    many_to_one :channel
    create_table unless table_exists?

    def before_create
      self.created_at = Time.now
    end
  end


end
