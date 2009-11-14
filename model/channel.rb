module Messager
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
end
