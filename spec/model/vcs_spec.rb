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

end
