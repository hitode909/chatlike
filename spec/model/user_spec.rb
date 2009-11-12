# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_helper'

describe MessageQueue::User do
  include MessageQueue
  before do
    load("message_queue/session")
    @user_a = load("message_queue/user__a")
    @user_b = load("message_queue/user__b")
    @user_c = load("message_queue/user__c")
  end

  it 'has user class' do
    @user_a.should be_an_instance_of MessageQueue::User
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
    @user_c.sessions.should be_empty
  end
end
