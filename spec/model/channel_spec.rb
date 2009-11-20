# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_helper'

describe SessionManager::Channel do
  include SessionManager
  before do
    load("session_manager/session")
    @ch_jp = load("session_manager/channel__japan")
    @ch_eu = load("session_manager/channel__euro")
    @session_a_ch_jp = load("session_manager/session__a_ch_jp")
    @session_b_ch_jp = load("session_manager/session__b_ch_jp")
    @user_a = load("session_manager/user__a")
    @user_b = load("session_manager/user__b")
  end

  it 'has user class' do
    @ch_jp.should be_an_instance_of SessionManager::Channel
  end

  it 'has columns' do
    @ch_jp.name.should == 'japan'
  end

  it 'may has sessions' do
    @ch_eu.sessions.should be_empty
    @ch_jp.sessions.length.should > 0
    @ch_jp.sessions.should include @session_a_ch_jp
    @ch_jp.sessions.should include @session_b_ch_jp
  end

  it 'may has members' do
    @ch_eu.members.should be_empty
    @ch_jp.members.length.should > 0
    @ch_jp.members.should include @user_a
    @ch_jp.members.should include @user_b
  end
end
