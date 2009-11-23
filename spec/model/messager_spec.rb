# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_helper'

describe SessionManager do
  before do
    load("session_manager/user")
  end

  it 'provides interfaces' do
    SessionManager.public_methods(true).should include("register")
    SessionManager.public_methods(true).should include("login")
    SessionManager.public_methods(true).should include("logout")
    SessionManager.public_methods(true).should include("get")
    SessionManager.public_methods(true).should include("post")
  end

  it 'provides register' do
    a = SessionManager.register('a', 'aa')

    a.user.name.should == 'a'
    b = SessionManager.register('b', 'bb')
    b.user.name.should == 'b'

    a.should_not == b
  end

  it 'provides register with channel' do
    s = SessionManager.register('a', 'aa', 'channel_a')
    s.channel.name.should == 'channel_a'
  end

  it 'rejects dupricate user' do
    SessionManager.register('f', 'ff')
    lambda {
      SessionManager.register('f', 'ff')
    }.should raise_error(SessionManager::DupricateUser)
  end

  it 'provides login' do
    a1 = SessionManager.register('a', 'aa')
    a2 = SessionManager.login('a', 'aa')

    a1.should_not == a2
  end

  it 'provides login with channel' do
    SessionManager.register('a', 'aa')
    s = SessionManager.login('a', 'aa', 'channel_a')
    s.channel.name.should == 'channel_a'
  end

  it 'rejects login of not registered user' do
    lambda {
      SessionManager.login('not', 'registerd')
    }.should raise_error(SessionManager::UserNotFound)
  end

  it 'provides session' do
    a1 = SessionManager.register('a', 'aa')
    a2 = SessionManager.login('a', 'aa')
    SessionManager.session(a1.random_key).should == a1
    SessionManager.session(a2.random_key).should == a2
    a1.user.should == a2.user
  end

  it 'session retrieves alive session only' do
    s = SessionManager.register('a', 'aa')
    s.kill
    SessionManager.session(s.random_key).should be_nil
  end

  it 'provides logout' do
    s = SessionManager.register('a', 'aa')
    SessionManager.logout(s.random_key)
    SessionManager.session(s.random_key).should be_nil
  end
end
