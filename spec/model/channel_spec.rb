# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_helper'

describe MessageQueue::Channel do
  include MessageQueue
  before do
    @ch_jp = load("message_queue/channel__japan")
    @ch_eu = load("message_queue/channel__euro")
    @session_a_ch_jp = load("message_queue/session__a_ch_jp")
    @session_b_ch_jp = load("message_queue/session__b_ch_jp")
  end

  it 'has user class' do
    @ch_jp.should be_an_instance_of MessageQueue::Channel
  end

  it 'has columns' do
    @ch_jp.name.should == 'japan'
  end

  it 'may has sessions' do
    @ch_eu.sessions.should be_empty
    @ch_jp.sessions.length.should == 2
    @ch_jp.sessions.should include @session_a_ch_jp
    @ch_jp.sessions.should include @session_b_ch_jp
  end
end
