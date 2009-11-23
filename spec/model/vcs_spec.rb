# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_helper'

describe Vcs do
  before do
     @user_a = load("messager/user__a")
     @hello = load("vcs/repository__hello_world")
     @child1 = load("vcs/repository__hello_world_child1")
     @child2 = load("vcs/repository__hello_world_child2")
  end

  it 'has repository class' do
    @hello.should be_an_instance_of Vcs::Repository
  end

  it 'has author' do
    @hello.author.should == @user_a
  end

  it 'has name' do
    @hello.name.should == "Hello, World"
  end

  it 'has path' do
    @hello.path.should == "hello_world"
  end

  it 'has global path' do
    @hello.global_path.should == "./svn/hello_world"
  end

  it 'may has parent' do
    @hello.parent.should be_nil
    @child1.parent.should == @hello
  end

  it 'may has children' do
    @hello.children.should include(@child1, @child2)
    @child1.children.should be_empty
  end

=begin
  it 'has files' do
    files = @hello.files
    files.should_not be_empty
    files.first.should be_an_instance_of Vcs::Repository::File
    files[0].path.should == "/"
    files[0].directory?.should be_true
    files[0].file?.should be_false
    lambda{ files[0].read }.should raise_error(Errno::EISDIR)

    files[1].path.should == "hello_world.c"
    files[1].directory?.should be_false
    files[1].file?.should be_true
    files[1].read.should =~ /Hello, World/
  end
=end

end

describe Vcs::Repository::Directory do
  before do
    @mydir = Vcs::Repository::Directory.new('mydir')
    @c1 = Vcs::Repository::Directory.new('child1')
    @c2 = Vcs::Repository::Directory.new('child2')
    @mydir.push(@c1)
    @mydir.push(@c2)
  end

  it 'is directory' do
    @mydir.directory?.should be_true
  end

  it 'has node_path' do
    @mydir.node_path.should == 'mydir'
  end

  it 'has files' do
    @mydir.files.length.should == 2
    @c1.parent.should == @mydir
    @c2.parent.should == @mydir
  end

  it 'has path' do
    @mydir.path.should == 'mydir'
    @c1.path.should == "mydir/child1"
    @c2.path.should == "mydir/child2"
  end

  it 'has iterator' do
    res = []
    @mydir.each { |f|
      res << f.path
    }
    res.should == @mydir.files.map{ |f| f.path }
  end
end

describe Vcs::Repository::File do
  before do
    @parent = Vcs::Repository::Directory.new('parent')
    @file = Vcs::Repository::File.new('myfile')
    @parent.push(@file)
  end

  it 'is file' do
    @file.file?.should be_true
    @file.directory?.should be_false
  end

  it 'has node_path' do
    @file.node_path.should == 'myfile'
  end

  it 'has path' do
    @file.path.should == 'parent/myfile'
  end

  # it 'can read'
end
