# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_helper'

describe Messager::Channel do
  include Messager
  before do
    load("messager/session")
    @ch_jp = load("messager/channel__japan")
    @ch_eu = load("messager/channel__euro")
    @session_a_ch_jp = load("messager/session__a_ch_jp")
    @session_b_ch_jp = load("messager/session__b_ch_jp")
    @user_a = load("messager/user__a")
    @user_b = load("messager/user__b")
  end

  it 'has user class' do
    @ch_jp.should be_an_instance_of Messager::Channel
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
