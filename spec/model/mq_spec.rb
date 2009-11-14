# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_helper'

describe MessageQueue do
  before do
    load("message_queue/user")
  end

  it 'provides interfaces' do
    MessageQueue.public_methods(true).should include("register")
    MessageQueue.public_methods(true).should include("login")
    MessageQueue.public_methods(true).should include("logout")
    MessageQueue.public_methods(true).should include("get")
    MessageQueue.public_methods(true).should include("post")
  end

  it 'provides register' do
    a = MessageQueue.register('a', 'aa')

    a.user.name.should == 'a'
    b = MessageQueue.register('b', 'bb')
    b.user.name.should == 'b'

    a.should_not == b
  end

  it 'rejects dupricate user' do
    MessageQueue.register('f', 'ff')
    lambda {
      MessageQueue.register('f', 'ff')
    }.should raise_error(MessageQueue::DupricateUser)
  end

  it 'provides login' do
    a1 = MessageQueue.register('a', 'aa')
    a2 = MessageQueue.login('a', 'aa')

    a1.should_not == a2
  end

  it 'rejects login of not registered user' do
    lambda {
      MessageQueue.login('not', 'registerd')
    }.should raise_error(MessageQueue::UserNotFound)
  end

  it 'provides session' do
    a1 = MessageQueue.register('a', 'aa')
    a2 = MessageQueue.login('a', 'aa')
    MessageQueue.session(a1.random_key).should == a1
    MessageQueue.session(a2.random_key).should == a2
    a1.user.should == a2.user
  end

  it 'session retrieves alive session only' do
    s = MessageQueue.register('a', 'aa')
    s.kill
    MessageQueue.session(s.random_key).should be_nil
  end

  it 'provides logout' do
    s = MessageQueue.register('a', 'aa')
    MessageQueue.logout(s.random_key)
    MessageQueue.session(s.random_key).should be_nil
  end
end
