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

    # XXX: need more test
    def root
      return @root if @root
      root = nil
      last = nil
      `svnlook tree #{self.global_path}`.split("\n").each{ |path|
        unless last
          root = Vcs::Repository::Directory.new('/')
          root.repository = self
          last = root
          next
        end

        depth = path.scan(/^ */).first.length
        while last.depth > depth
          last = last.parent
        end
        last.push(path.strip!)
        last = last.files.last
      }
      @root = root
    end

    def clear_cache
      @root = nil
    end

    def global_path
      ::File.join(Vcs::GLOBAL_PATH, self.path)
    end
  end

  class Repository::Entity
    attr_accessor :repository, :parent, :node_path, :depth
    def initialize(node_path)
      @depth = 0
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

    def push(path)
      if path =~ /\/$/
        entity = Repository::Directory.new(path)
      else
        entity = Repository::File.new(path)
      end
      self.files << entity
      entity.parent = self
      entity.repository = self.repository
      entity.depth = self.depth + 1
    end

    def file?
      false
    end

    def each(&block)
      self.files.each {|b|
        yield(b)
      }
    end

    def method_missing(name, *args)
      @files.__send__(name, *args)
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
