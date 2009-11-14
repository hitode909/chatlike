require 'securerandom'

module Messager
  class SessionNotFound < Exception;end
  class Session < Sequel::Model
    set_schema do
      primary_key :id
      String :random_key, :unique => true
      foreign_key :user_id, :null => false
      foreign_key :channel_id
      time :created_at
      time :expire_at
      Integer :last_fetched, :null => false, :default => 0
      Boolean :is_alive, :default => true
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
      query = Messager::Message.filter(:channel_id => self.channel_id, :receiver_id => self.user_id)
      query.or!(:channel_id => self.channel_id, :receiver_id => nil) if self.channel_id
      query.or!(:channel_id => nil, :receiver_id => nil
        ).filter!(:id > self.last_fetched
        ).filter!({:loopback => true} | ({:loopback => false} & ~{:author_session_id => self.id})
        ).order!(:id.asc)
      m = query.first
      if m
        self.last_fetched = m.id
      end
      m
    end
  end
end
