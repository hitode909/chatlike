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
    a1 = MessageQueue.register('a', 'aa')
    a2 = MessageQueue.login('a', 'aa')
    a1.should == a2

    b = MessageQueue.register('b', 'bb')
    a1.should_not == b
  end


end
