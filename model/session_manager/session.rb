require 'securerandom'

module SessionManager
  class SessionNotFound < Exception;end
  class Session < Sequel::Model
    set_schema do
      primary_key :id
      String :random_key, :unique => true
      foreign_key :user_id, :null => false
      foreign_key :channel_id
      datetime :created_at
      datetime :expire_at
      Integer :last_fetched, :null => false, :default => 0
      Boolean :is_alive, :default => true
    end
    many_to_one :user
    many_to_one :channel
    create_table unless table_exists?

    def to_hash
      {
        :random_key => self.random_key,
        :user_name  => self.user.name,
        :channel => self.channel ? self.channel.name : nil
      }
    end

    def before_create
      self.created_at = Time.now
      self.expire_at  = Time.now + self.expire_duration
      self.random_key = SecureRandom.hex(32)
    end

    def update_expire
      self.expire_at = Time.now + self.expire_duration
    end

    def expire_duration
      120
    end

    def kill
      self.expire_at = Time.now - 1
      self.is_alive = false
      self.save
    end

    def update_state
      if self.is_alive and  self.expire_at < Time.now
        self.kill
        return true
      else
        return false
      end
    end

    def post_message(body, option = { })
      option.update(
        :body => body,
        :author => self.user,
        :author_session => self
      )
      Message.create(option)
    end

    def post_json_message(body, option = { })
      option.update(
        :body => body.to_json,
        :author => self.user,
        :author_session => self,
        :is_json => true
      )
      Message.create(option)
    end

    def post_message_to_channel(body, option = { })
      option.update(
        :body => body,
        :author => self.user,
        :author_session => self,
        :channel => self.channel
      )
      Message.create(option)
    end

    def post_system_message_to_channel(body, option = { })
      option.update(
        :body => body,
        :author => self.user,
        :author_session => self,
        :channel => self.channel,
        :is_system => true,
        :loopback => true
      )
      Message.create(option)
    end

    def post_message_to_me(body, option = { })
      option.update(
        :body => body,
        :author => self.user,
        :author_session => self,
        :receiver => self.user
      )
      Message.create(option)
    end

    def receive_message(all = false)
      query = SessionManager::Message.filter(:channel_id => self.channel_id, :receiver_id => self.user_id)
      query.or!(:channel_id => self.channel_id, :receiver_id => nil) if self.channel_id
      query.or!(:channel_id => nil, :receiver_id => nil
        ).filter!(:id > self.last_fetched
        ).filter!({:loopback => true} | ({:loopback => false} & ~{:author_session_id => self.id})
        ).order!(:id.asc)
      query.filter!(:created_at >= self.created_at) unless all
      m = query.first
      if m
        self.last_fetched = m.id
        self.save
      end
      m
    end

    def has_repository?(repos)
      !!Vcs::Repository.find(:author_id => self.user.id, :name => repos.name)
    end
  end
end
