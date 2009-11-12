# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_helper'

describe MessageQueue::Session do
  include MessageQueue
  before do
    @session_a = load("message_queue/session__a")
    @session_a_2 = load("message_queue/session__a_2")
    @session_b = load("message_queue/session__b")
    @user_a = load("message_queue/user__a")
    @ch_jp = load("message_queue/channel__japan")
    @session_a_ch_jp = load("message_queue/session__a_ch_jp")
  end

  it 'has session class' do
    @session_a.should be_an_instance_of MessageQueue::Session
  end

  it 'has a user' do
    @session_a.user.should == @user_a
  end

  it 'may has a channel' do
    @session_a.channel.should be_nil
    @session_a_ch_jp.channel.should == @ch_jp
  end

   it 'has random key' do
     @session_a.random_key.should be_an_instance_of String
   end

   it 'tokens will differ' do
     @session_a.random_key.should_not == @session_b.random_key
     @session_a.random_key.should_not == @session_a_2.random_key
   end
end
