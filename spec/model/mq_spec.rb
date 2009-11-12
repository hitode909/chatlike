# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require 'model/mq'

describe MessageQueue::User do
  before do
    @user1 = MessageQueue::User.new 'user1', 'password'
    @user2 = MessageQueue::User.new 'user2', 'password'
  end

  it 'has user class' do
    @user1.should be_an_instance_of MessageQueue::User
  end

  it 'has name' do
    @user1.name.should == 'user1'
  end

  it 'has password (private)' do
    @user1.should_not respond_to :password
    @user1.instance_variable_get(:@password).should == 'password'
  end

  it 'has token' do
    @user1.token.should be_an_instance_of String
  end

  it 'tokens will differ' do
    @user1.token.should_not == @user2.token
  end
end

describe MessageQueue::Session do
  before do
    @now = Time.now
    Time.stub!(:now).and_return @now
    @user = MessageQueue::User.new 'user', 'password'
    @session = MessageQueue::Session.new @user
  end

  it 'has user' do
    @session.user.should == @user
  end

  it 'has token' do
    @session.token.should be_an_instance_of String
    session2 = MessageQueue::Session.new @user
    @session.token.should_not == session2.token
  end

  it 'has created_at' do
    @session.created_at.should be_an_instance_of Time
    @session.created_at.should == @now
  end

  it 'has alive?' do
    @session.alive?.should be_true
    Time.stub!(:now).and_return @now + @session.expire + 10
    @session.alive?.should be_false
  end
end

describe MessageQueue do
  it 'can register with user and password' do
    MessageQueue.should respond_to(:register)
  end

  it 'provides register' do
    MessageQueue.register('user', 'password').should be_an_instance_of String
    t1 = MessageQueue.register('user1', 'password')
    t2 = MessageQueue.register('user2', 'password')
    t1.should_not == t2
  end

  it 'provides login with name and password' do
    t1 = MessageQueue.login('user1', 'password')
    t2 = MessageQueue.login('user2', 'password')
    t1_2 = MessageQueue.login('user1', 'password')
    t2_2 = MessageQueue.login('user2', 'password')
    t1.should == t1_2
    t2.should == t2_2
    t1.should_not == t2_2
    t1.should be_an_instance_of String
    t2.should be_an_instance_of String
  end

  it 'provides session' do
    MessageQueue.join_session
  end
end






# -----------



=begin
  it 'is comparable' do
    u1 = MessageQueue::User.new('u', 'p')
    u2 = MessageQueue::User.new('u', 'p')
    u3 = MessageQueue::User.new('u2', 'p')
    u1.eql?(u2).should == true
    #u1.should_not == u3
  end
=end

