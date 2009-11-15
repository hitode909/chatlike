require File.dirname(__FILE__) + '/../spec_helper'
require 'ramaze'
require 'ramaze/spec/bacon'
require __DIR__('../../app')

describe MainController do
  behaves_like :rack_test

  before do
    delete_test_db
    Messager.register('a', 'a')
    Messager.register('b', 'b')
  end

  should 'can register' do
    post('/api/register', :name => 'newa', :password => 'newa')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["data"].class.should == Hash
    json(last_response.body)["data"]["random_key"].length.should > 0
    json(last_response.body)["data"]["user_name"].should == "newa"
    json(last_response.body)["data"]["channel"].should == nil
  end

  should 'can register with channel' do
    post('/api/register', :name => 'newa', :password => 'newa', :channel => "cha")
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["data"].class.should == Hash
    json(last_response.body)["data"]["random_key"].length.should > 0
    json(last_response.body)["data"]["user_name"].should == "newa"
    json(last_response.body)["data"]["channel"].should == "cha"
  end

  should 'cannot register dupricate user' do
    post('/api/register', :name => 'newb', :password => 'newb')
    json(last_response.body)["status"].should == "ok"
    post('/api/register', :name => 'newb', :password => 'newb')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["error"].should.include("DupricateUser")
  end

  should 'can login' do
    post('/api/login', :name => 'a', :password => 'a')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["data"].class.should == Hash
    json(last_response.body)["data"]["random_key"].length.should > 0
    json(last_response.body)["data"]["user_name"].should == "a"
    json(last_response.body)["data"]["channel"].should == nil
  end

  should 'can login with channel' do
    post('/api/login', :name => 'a', :password => 'a', :channel => "cha")
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["data"].class.should == Hash
    json(last_response.body)["data"]["random_key"].length.should > 0
    json(last_response.body)["data"]["user_name"].should == "a"
    json(last_response.body)["data"]["channel"].should == "cha"
  end

  should 'cannot login with invalid user' do
    post('/api/login', :name => 'a', :password => 'foobar')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["error"].should.include("UserNotFound")
  end

  # XXX: channel

  should 'can post message' do
    post('/api/login', :name => 'a', :password => 'a')
    token = json(last_response.body)["data"]["random_key"]

    post('/api/post', :session => token, :body => 'hello')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
  end

  should 'cannot post without body' do
    post('/api/login', :name => 'a', :password => 'a')
    token = json(last_response.body)["data"]["random_key"]

    post('/api/post', :session => token)
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["error"].should.include("BodyRequired")
  end

  should 'cannot post without session' do
    post('/api/post', :body => "cool")
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["error"].should.include("SessionRequired")
  end

  should 'can get message' do
    post('/api/login', :name => 'a', :password => 'a')
    token_a = json(last_response.body)["data"]["random_key"]

    post('/api/login', :name => 'b', :password => 'b')
    token_b = json(last_response.body)["data"]["random_key"]

    post('/api/post', :body => "hello", :session => token_a)
    post('/api/post', :body => "world", :session => token_a)

    get('/api/get', :session => token_b)
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["data"].should == "hello"

    get('/api/get', :session => token_b)
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["data"].should == "world"

    get('/api/get', :session => token_b)
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["data"].should == ""
  end

end
