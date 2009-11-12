# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_helper'

describe MessageQueue::Channel do
  include MessageQueue
  before do
    @ch_jp = load("message_queue/channel__japan")
    @ch_eu = load("message_queue/channel__euro")
  end

  it 'has user class' do
    @ch_jp.should be_an_instance_of MessageQueue::Channel
  end

  it 'has columns' do
    @ch_jp.name.should == 'japan'
  end
end
