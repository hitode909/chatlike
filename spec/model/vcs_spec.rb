# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_helper'

describe Vcs do
  before do
     @user_a = load("messager/user__a")
     @hello = load("vcs/repository__hello_world")
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

  it 'has is_valid' do
    @hello.is_valid.should be_true
  end

  it 'has path' do
    @hello.path.should == "hello_world"
  end

  it 'has global path' do
    @hello.global_path.should == "./hello_world"
  end

  it 'may has parent' do
    @hello.parent.should be_nil
    # XXX: @hello_child.parent.should == @hello
  end

  it 'may has children' do
    @hello.children.should be_empty
  end

end
