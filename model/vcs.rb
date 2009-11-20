module Vcs
  class Repository < Sequel::Model
    set_schema do
      primary_key :id
      String :path, :unique => true
      String :name
      foreign_key :author_id, :null => false
      foreign_key :parent_id
      Boolean :is_valid, :null => false, :default => false
      datetime :created_at
    end
    many_to_one :author, :class => Messager::User
    many_to_one :parent, :class => Repository
    one_to_many :children, :class => Repository, :key => :parent_id
    create_table unless table_exists?
    def before_create
      self.created_at = Time.now
    end

    def is_valid
      self.values[:is_valid]
    end

    def files
    end

    def global_path
      ::File.join(Vcs::GLOBAL_PATH, self.path)
    end
  end

  class Repository::File
    def initialize()
    end
    def path
    end

    def read
      # svnlook
    end
  end

  GLOBAL_PATH = "./"
end
