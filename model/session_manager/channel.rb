module SessionManager
  class Channel < Sequel::Model
    set_schema do
      primary_key :id
      String :name, :unique => true
    end

    one_to_many :sessions do |ds|
      ds.filter('expire_at > ?', Time.now)
    end

    create_table unless table_exists?

    def members
      sessions.map(&:user).uniq
    end

    def all_sessions
      Session.filter('channel_id = ?', self.id).all
    end

    def invalid_sessions
      Session.filter('channel_id = ? and expire_at < ? and is_alive = ?', self.id, Time.now, true).all
    end
  end
end
