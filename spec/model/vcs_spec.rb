# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_helper'

describe Vcs do
  before do
     @user_a = load("session_manager/user__a")
     @user_b = load("session_manager/user__b")
     @user_c = load("session_manager/user__c")
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
    @hello.name.should == "hello_world"
  end

  it 'has path' do
    @hello.path.should == "user_a/hello_world"
  end

  it 'has global path' do
    @hello.global_path.should == "./svn/user_a/hello_world"
  end

  it 'may has parent' do
    @hello.parent.should be_nil
    @child1.parent.should == @hello
  end

  it 'may has children' do
    @hello.children.should include(@child1, @child2)
    @child1.children.should be_empty
  end

  it 'has files' do
    root = @hello.root
    root.should be_an_instance_of Vcs::Repository::Directory
    root.should_not be_empty
    root.path.should == "/"
    lambda{ root.read }.should raise_error(Errno::EISDIR)
    root.directory?.should be_true
    root.file?.should be_false

    root.first.should be_an_instance_of Vcs::Repository::File
    root.first.file?.should be_true
    root.first.directory?.should be_false
    root.first.node_path.should == "hello_world.c"
    root.first.path.should == "/hello_world.c"
    root.first.read.should =~ /Hello, World/
  end

end

describe Vcs::Repository::Directory do
  before do
    @mydir = Vcs::Repository::Directory.new('mydir')
    @mydir.push('child1')
    @mydir.push('child2')
    @c1, @c2 = *@mydir.files
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
    @parent.push('myfile')
    @file = @parent.last
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
