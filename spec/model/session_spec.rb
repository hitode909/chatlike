# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_helper'

describe SessionManager::Session do
  include SessionManager
  before do
    @session_a = load("session_manager/session__a")
    @session_a_2 = load("session_manager/session__a_2")
    @session_b = load("session_manager/session__b")
    @user_a = load("session_manager/user__a")
    @user_b = load("session_manager/user__b")
    @user_c = load("session_manager/user__c")
    @session_c = load("session_manager/session__c")
    @session_a_ch_jp = load("session_manager/session__a_ch_jp")
  end

  it 'has session class' do
    @session_a.should be_an_instance_of SessionManager::Session
  end

  it 'has a user' do
    @session_a.user.should == @user_a
  end

  it 'may has a channel' do
    @ch_jp = load("session_manager/channel__japan")
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

  it 'can cast to hash' do
    hash = @session_a.to_hash
    hash.should be_an_instance_of Hash
    hash[:random_key].should == @session_a.random_key
    hash[:user_name].should == @session_a.user.name
    hash[:channel].should be_nil

    @session_a_ch_jp.to_hash[:channel].should == @session_a_ch_jp.channel.name
  end

  it 'has expire' do
    @now = Time.now
    Time.stub!(:now).and_return @now

    @session_a.is_alive.should be_true
    @session_a.update_state.should be_false

    @now += @session_a.expire_duration * 2
    Time.stub!(:now).and_return @now
    @session_a.update_state.should be_true
    @session_a.is_alive.should be_false
  end

  it 'will die when killed' do
    @session_a.is_alive.should be_true
    @session_a.kill
    @session_a.is_alive.should be_false
  end

  it 'has relation to channnel.sessions' do
    load("session_manager/session")
    @ch_jp = load("session_manager/channel__japan")
    before = @ch_jp.sessions
    @session_a_ch_jp.kill

    @ch_jp.refresh
    @ch_jp.sessions.length.should < before.length
    @ch_jp.all_sessions.length.should == before.length
  end

  it 'has relation to user.sessions' do
    load("session_manager/session")
    before = @user_a.sessions
    @session_a_ch_jp.kill

    @user_a.refresh
    @user_a.sessions.length.should < before.length
    @user_a.all_sessions.length.should == before.length
  end

  it 'posts messages' do
    m = @session_a.post_message 'm1'
    m.should be_an_instance_of SessionManager::Message
    m.body.should == 'm1'
    m.author.should == @session_a.user
    m.author_session.should == @session_a
    m.channel.should be_nil
    m.receiver.should be_nil
  end

  it 'post message to channel' do
    @ch_jp = load("session_manager/channel__japan")
    m = @session_a_ch_jp.post_message_to_channel 'jp'
    m.should be_an_instance_of SessionManager::Message
    m.body.should == 'jp'
    m.channel.should == @ch_jp
    m.receiver.should be_nil
  end

  it 'post system message to channel' do
    @ch_jp = load("session_manager/channel__japan")
    m = @session_a_ch_jp.post_system_message_to_channel 'sys'
    m.should be_an_instance_of SessionManager::Message
    m.is_system.should be_true
    m.body.should == 'sys'
    m.channel.should == @ch_jp
    m.receiver.should be_nil
  end

  it 'post message to me' do
    m = @session_a.post_message_to_me 'me'
    m.should be_an_instance_of SessionManager::Message
    m.body.should == 'me'
    m.channel.should == nil
    m.receiver.should == @session_a.user
  end

  it 'receive broadcast messages' do
    @session_b.receive_message.should be_nil
    @session_a.post_message 'm'
    m = @session_b.receive_message
    m.should be_an_instance_of SessionManager::Message
    m.body.should == 'm'
    @session_a.receive_message.should be_nil
  end

  it 'receive messages in order' do
    (1..5).each { |i| @session_a.post_message i }
    Array.new(5){ @session_b.receive_message }.map{ |m| m.body}.should == (1..5).to_a.map{ |i| i.to_s }
  end

  it 'receive messages to user' do
    @session_a.post_message 'to_b', :receiver => @user_b
    @session_b.receive_message.body.should == 'to_b'
    @session_a.receive_message.should be_nil
    @session_c.receive_message.should be_nil
  end

  it 'receive messages to channel' do
    @session_b_ch_jp = load("session_manager/session__b_ch_jp")
    @session_c_ch_jp = load("session_manager/session__c_ch_jp")
    @session_a.post_message 'to_jp', :channel => load("session_manager/channel__japan")
    @session_b_ch_jp.receive_message.body.should == 'to_jp'
    @session_c_ch_jp.receive_message.body.should == 'to_jp'
    @session_b.receive_message.should be_nil
    @session_c.receive_message.should be_nil
  end

  it 'receive messages to channel in the user' do
    @session_b_ch_jp = load("session_manager/session__b_ch_jp")
    @session_c_ch_jp = load("session_manager/session__c_ch_jp")
    @session_a.post_message('to_b_jp',
      :receiver => @user_b,
      :channel => load("session_manager/channel__japan")
      )
    @session_b_ch_jp.receive_message.body.should == 'to_b_jp'
    @session_b.receive_message.should be_nil
    @session_c_ch_jp.receive_message.should be_nil
  end

  it 'receives my message when loopback' do
    @session_a.post_message 'broadcast loopback', :loopback => true
    @session_b.receive_message.body.should == 'broadcast loopback'
    @session_a.receive_message.body.should == 'broadcast loopback'
  end
end
