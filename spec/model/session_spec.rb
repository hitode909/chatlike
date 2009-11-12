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
    @session_a_ch_jp = load("message_queue/session__a_ch_jp")
  end

  it 'has session class' do
    @session_a.should be_an_instance_of MessageQueue::Session
  end

  it 'has a user' do
    @session_a.user.should == @user_a
  end

  it 'may has a channel' do
    @ch_jp = load("message_queue/channel__japan")
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

  it 'has expire' do
    @now = Time.now
    Time.stub!(:now).and_return @now

    @session_a.is_alive.should be_true

    @now += @session_a.expire_duration * 2
    Time.stub!(:now).and_return @now

    @session_a.still_alive.should be_false
  end

  it 'will die when killed' do
    @session_a.is_alive.should be_true
    @session_a.kill
    @session_a.is_alive.should be_false
  end

  it 'will die when expired' do
    @now = Time.now
    @session_a.is_alive.should be_true

    Time.stub!(:now).and_return @now

    @session_a.check_alive
    @session_a.is_alive.should be_true

    Time.stub!(:now).and_return @now + @session_a.expire_duration * 2

    @session_a.check_alive
    @session_a.is_alive.should be_false
  end

  it 'has relation to channnel.sessions' do
    load("message_queue/session")
    @ch_jp = load("message_queue/channel__japan")
    before = @ch_jp.sessions
    @session_a_ch_jp.kill

    @ch_jp.refresh
    @ch_jp.sessions.length.should < before.length
    @ch_jp.all_sessions.length.should == before.length
  end
end
