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
      # directory will apear as indent
      `svnlook tree #{self.global_path}`.split("\n").map{ |path|
        Repository::File.new(self, path.strip)
      }
    end

    def global_path
      ::File.join(Vcs::GLOBAL_PATH, self.path)
    end
  end

  class Repository::Entity
    attr_accessor :repository, :parent, :node_path
    def initialize(node_path)
      @node_path = node_path
    end

    def path
      self.parent ? ::File.join(self.parent.path , self.node_path) : self.node_path
    end
  end

  class Repository::Directory < Repository::Entity
    attr_accessor :files

    def initialize(n)
      @files = []
      super(n)
    end

    def read
      raise Errno::EISDIR
    end

    def directory?
      true
    end

     def each(&block)
       self.files.each {|b|
         yield(b)
       }
     end

    def push(entity)
      raise TypeError unless entity.kind_of? Vcs::Repository::Entity
      self.files << entity
      entity.parent = self
    end

    def file?
      false
    end
  end

  class Repository::File < Repository::Entity

    def read
      `svnlook cat #{self.repository.global_path} #{path}`
    end

    def file?
      true
    end

    def directory?
      false
    end
  end

  GLOBAL_PATH = "./svn/"
end
