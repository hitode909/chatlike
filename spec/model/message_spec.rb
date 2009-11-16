# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_helper'

describe Messager::Message do
  before do
    @user_a = load("messager/user__a")
    @session_a = load("messager/session__a")
    @m_br, @m_us, @m_ch = * load(%w{ messager/message__broadcast messager/message__to_user_b messager/message__to_channel_japan})
  end

  it 'has user class' do
    @m_br.should be_an_instance_of Messager::Message
    @user_a = load("messager/user__a")
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
    @user_b = load("messager/user__b")
    @m_us.receiver.should == @user_b
  end

  it 'may have channel' do
    @m_br.channel.should be_nil
    @uch_jp = load("messager/channel__japan")
    @m_ch.receiver.should == @ch_jp
  end

  it 'can cast to hash' do
    @m_br.to_hash.should be_kind_of Hash
    @m_br.to_hash[:body].should == 'broadcast'
    @m_br.to_hash[:created_at].should be_kind_of Time
    @m_br.to_hash[:author].should == 'user_a'
    @m_us.to_hash[:receiver].should == 'user_b'
    @m_ch.to_hash[:channel].should == 'japan'
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
    new_user = Messager::User.create(:name => 'new', :password => 'none')
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
