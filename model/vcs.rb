module Vcs
  class Repository < Sequel::Model
    set_schema do
      primary_key :id
      String :path, :unique => true
      String :name
      foreign_key :author_id, :null => false
      foreign_key :parent_id
      datetime :created_at
    end
    many_to_one :author, :class => Messager::User
    many_to_one :parent, :class => Repository
    one_to_many :children, :class => Repository, :key => :parent_id
    create_table unless table_exists?
    def before_create
      self.created_at = Time.now
    end

    def files
      `svnlook tree #{self.global_path}`.split("\n").map{ |path|
        Repository::File.new(self, path.strip)
      }
    end

    def global_path
      ::File.join(Vcs::GLOBAL_PATH, self.path)
    end
  end

  class Repository::File
    attr_reader :repository, :path
    def initialize(repository, path)
      @repository, @path = repository, path
    end

    def read
      raise Errno::EISDIR, self.path if self.directory?
      `svnlook cat #{self.repository.global_path} #{path}`
    end

    def file?
      not self.directory?
    end

    def directory?
      !!(self.path.strip =~ /\/$/)
    end
  end

  GLOBAL_PATH = "./svn/"
end
