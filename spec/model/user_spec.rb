# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_helper'

describe SessionManager::User do
  include SessionManager
  before do
    load("session_manager/session")

    @user_a = load("session_manager/user__a")
    @user_b = load("session_manager/user__b")
    @user_c = load("session_manager/user__c")
  end

  it 'has user class' do
    @user_a.should be_an_instance_of SessionManager::User
  end

  it 'has columns' do
    @user_a.name.should == 'user_a'
    @user_a.password.should == 'foobar'
  end

  it 'has random key' do
    @user_a.random_key.should be_an_instance_of String
  end

  it 'tokens will differ' do
    @user_a.random_key.should_not == @user_b.random_key
  end

  it 'may has sessions' do
    @user_a.sessions.length.should > 0
    new_user = SessionManager::User.create(:name => 'new', :password => 'none')
    new_user.sessions.should be_empty
  end

  it 'provides create_session' do
    before = @user_a.sessions.length
    s = @user_a.create_session
    s.user.should == @user_a
    s.channel.should be_nil
    @user_a.refresh.sessions.length.should == before + 1
  end

  it 'provides create_session with channel' do
    s = @user_a.create_session('ping-pong')
    s.channel.name.should == 'ping-pong'
  end

end
