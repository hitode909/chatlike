module MessageQueue
  class Message < Sequel::Model
    set_schema do
      primary_key :id
      String :body, :null => false
      foreign_key :author_id, :null => false
      foreign_key :author_session_id, :null => false
      foreign_key :receiver_id
      foreign_key :channel_id
      Boolean :loopback, :null => false, :default => false
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
