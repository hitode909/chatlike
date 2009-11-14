# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_helper'

describe MessageQueue::Message do
  before do
    @user_a = load("message_queue/user__a")
    @session_a = load("message_queue/session__a")
    @m_br, @m_us, @m_ch = * load(%w{ message_queue/message__broadcast message_queue/message__to_user_b message_queue/message__to_channel_japan})
  end

  it 'has user class' do
    @m_br.should be_an_instance_of MessageQueue::Message
    @user_a = load("message_queue/user__a")
  end

  it 'has body' do
    @m_br.body.should == 'broadcast'
    @m_us.body.should == 'user'
    @m_ch.body.should == 'channel'
  end

  it 'has author and author session' do
    @m_br.author.should == @user_a
    @m_br.author_session.should == @session_a
  end

  it 'may have receiver' do
    @m_br.receiver.should be_nil
    @user_b = load("message_queue/user__b")
    @m_us.receiver.should == @user_b
  end

  it 'may have channel' do
    @m_br.channel.should be_nil
    @uch_jp = load("message_queue/channel__japan")
    @m_ch.receiver.should == @ch_jp
  end

=begin
  it 'has random key' do
    @user_a.random_key.should be_an_instance_of String
  end

  it 'tokens will differ' do
    @user_a.random_key.should_not == @user_b.random_key
  end

  it 'may has sessions' do
    @user_a.sessions.length.should > 0
    new_user = MessageQueue::User.create(:name => 'new', :password => 'none')
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
=end

end
