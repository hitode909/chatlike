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
    many_to_one :author, :class => ::SessionManager::User
    many_to_one :parent, :class => Repository
    one_to_many :children, :class => Repository, :key => :parent_id
    create_table unless table_exists?
    def before_create
      self.created_at = Time.now
      user = SessionManager::User.find(:id => self.author_id)
      self.path = user.name + "/" + self.name
    end

    def entities
      unless @root
        self.root
      end
      @entities
    end

    # XXX: need more test
    def root
      return @root if @root
      @entities = []
      root = nil
      last = nil
      `svnlook tree #{self.inner_path}`.split("\n").each{ |path|
        unless last
          root = Vcs::Repository::Directory.new('/')
          root.repository = self
          last = root
          @entities.push(last)
          next
        end

        depth = path.scan(/^ */).first.length
        while last.depth >= depth
          last = last.parent
        end
        last.push(path.strip!)
        last = last.last
        @entities.push(last)
      }
      @root = root
    end

    def clear_cache
      @root = nil
    end

    def inner_path
      ::File.join(Vcs::INNER_ROOT, self.path)
    end

    def user_path
      ::File.join(Vcs::INNER_ROOT, self.author.name)
    end

    def web_path
      Vcs::WEB_ROOT + 'repository/' + self.path
    end

    def repository_path
      Vcs::REPOSITORY_ROOT + self.path
    end

    def to_hash
      {
        :path => self.path,
        :repository_path => self.repository_path,
        :web_path => self.web_path,
        :name => self.name,
        :author => self.author.name,
        :created_at => self.created_at
      }
    end

    def write_passwd
      ::File.open(::File.join(self.inner_path, '/conf/passwd'), 'w') { |f|
        f.puts "[users]"
        f.puts "#{self.author.name} = #{self.author.password}"
      }
      ::File.open(::File.join(self.inner_path, '/conf/svnserve.conf'), 'w') { |f|
        f.puts "[general]"
        f.puts "anon-access = read"
        f.puts "password-db = passwd"
      }
    end

    def fork(user)
      already = Repository.find(:author_id => user.id, :name => self.name)
      raise 'DupricateRepository' if already
      begin
        new = Repository.create(
          :author_id => user.id,
          :name => self.name,
          :parent => self
          )
        puts "mkdir -p #{new.user_path}"
        system "mkdir -p #{new.user_path}"
        puts "cp -r #{self.inner_path} #{new.user_path}"
        system "cp -r #{self.inner_path} #{new.user_path}"
        new.write_passwd
        new
      rescue => e
        system "rm -rf #{new.inner_path}"
        new.delete
        e
      end
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
      `svnlook cat #{self.repository.inner_path} #{path}`
    end

    def file?
      true
    end

    def directory?
      false
    end
  end

  INNER_ROOT = "./svn/"
  REPOSITORY_ROOT = 'svn://localhost/'
  WEB_ROOT = 'http://localhost:7000/'
end
