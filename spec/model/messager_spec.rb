# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../model_helper'

describe Messager do
  before do
    load("messager/user")
  end

  it 'provides interfaces' do
    Messager.public_methods(true).should include("register")
    Messager.public_methods(true).should include("login")
    Messager.public_methods(true).should include("logout")
    Messager.public_methods(true).should include("get")
    Messager.public_methods(true).should include("post")
  end

  it 'provides register' do
    a = Messager.register('a', 'aa')

    a.user.name.should == 'a'
    b = Messager.register('b', 'bb')
    b.user.name.should == 'b'

    a.should_not == b
  end

  it 'rejects dupricate user' do
    Messager.register('f', 'ff')
    lambda {
      Messager.register('f', 'ff')
    }.should raise_error(Messager::DupricateUser)
  end

  it 'provides login' do
    a1 = Messager.register('a', 'aa')
    a2 = Messager.login('a', 'aa')

    a1.should_not == a2
  end

  it 'rejects login of not registered user' do
    lambda {
      Messager.login('not', 'registerd')
    }.should raise_error(Messager::UserNotFound)
  end

  it 'provides session' do
    a1 = Messager.register('a', 'aa')
    a2 = Messager.login('a', 'aa')
    Messager.session(a1.random_key).should == a1
    Messager.session(a2.random_key).should == a2
    a1.user.should == a2.user
  end

  it 'session retrieves alive session only' do
    s = Messager.register('a', 'aa')
    s.kill
    Messager.session(s.random_key).should be_nil
  end

  it 'provides logout' do
    s = Messager.register('a', 'aa')
    Messager.logout(s.random_key)
    Messager.session(s.random_key).should be_nil
  end
end
