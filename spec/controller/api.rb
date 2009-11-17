require File.dirname(__FILE__) + '/../spec_helper'
require 'ramaze'
require 'ramaze/spec/bacon'
require __DIR__('../../app')

describe MainController do
  behaves_like :rack_test

  before do
    delete_test_db
    @session_a = Messager.register('a', 'a')
    @session_b = Messager.register('b', 'b')
    @session_c = Messager.register('c', 'c')
    @session_a_cool = Messager.login('a', 'a', 'cool')
    @session_b_cool = Messager.login('b', 'b', 'cool')
    @session_c_cool = Messager.login('c', 'c', 'cool')
    @session_a_hot =  Messager.login('a', 'a', 'hot')
  end

  should 'can register' do
    post('/api/register', :name => 'newa', :password => 'newa')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["session"].class.should == Hash
    json(last_response.body)["session"]["random_key"].length.should > 0
    json(last_response.body)["session"]["user_name"].should == "newa"
    json(last_response.body)["session"]["channel"].should == nil
  end

  should 'can register with channel' do
    post('/api/register', :name => 'newa', :password => 'newa', :channel => "cha")
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["session"].class.should == Hash
    json(last_response.body)["session"]["random_key"].length.should > 0
    json(last_response.body)["session"]["user_name"].should == "newa"
    json(last_response.body)["session"]["channel"].should == "cha"
  end

  should 'cannot register dupricate user' do
    post('/api/register', :name => 'newb', :password => 'newb')
    json(last_response.body)["status"].should == "ok"
    post('/api/register', :name => 'newb', :password => 'newb')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["errors"].should.include("DupricateUser")
  end

  should 'can login' do
    post('/api/login', :name => 'a', :password => 'a')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["session"].class.should == Hash
    json(last_response.body)["session"]["random_key"].length.should > 0
    json(last_response.body)["session"]["user_name"].should == "a"
    json(last_response.body)["session"]["channel"].should == nil
  end

  should 'can login with channel' do
    post('/api/login', :name => 'a', :password => 'a', :channel => "cha")
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["session"].class.should == Hash
    json(last_response.body)["session"]["random_key"].length.should > 0
    json(last_response.body)["session"]["user_name"].should == "a"
    json(last_response.body)["session"]["channel"].should == "cha"
  end

  should 'cannot login with invalid user' do
    post('/api/login', :name => 'a', :password => 'foobar')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["errors"].should.include("UserNotFound")
  end

  # XXX: channel

  should 'can post message' do
    post('/api/post', :session => @session_a.random_key, :body => 'hello')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["message"]["author"].should == 'a'
    json(last_response.body)["message"]["body"].should == 'hello'
    json(last_response.body)["message"]["channel"].should == nil
    json(last_response.body)["message"]["receiver"].should == nil
  end

  should 'cannot post without body' do
    post('/api/post', :session => @session_a.random_key)
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["errors"].should.include("BodyRequired")
  end

  should 'cannot post without session' do
    post('/api/post', :body => "cool")
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["errors"].should.include("SessionRequired")
  end

  should 'can get message' do
    post('/api/post', :body => "hello", :session => @session_a.random_key)
    post('/api/post', :body => "world", :session => @session_a.random_key)

    get('/api/get', :session => @session_b.random_key)
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["message"]["body"].should == "hello"
    json(last_response.body)["message"]["author"].should == "a"
    json(last_response.body)["message"]["receiver"].should == nil
    json(last_response.body)["message"]["channel"].should == nil

    get('/api/get', :session => @session_b.random_key)
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["message"]["body"].should == "world"

    get('/api/get', :session => @session_b.random_key)
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["message"].should == nil
  end

  should 'can post or get with channel' do
    post('/api/post', :body => "hi, cool", :session => @session_a_cool.random_key)
    get('/api/get', :session => @session_b_cool.random_key)
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["message"]["body"].should == "hi, cool"
    json(last_response.body)["message"]["author"].should == "a"
    json(last_response.body)["message"]["receiver"].should == nil
    json(last_response.body)["message"]["channel"].should == "cool"

    get('/api/get', :session => @session_a_cool.random_key)
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["message"].should == nil
  end

  should 'can post or get with receiver' do
    post('/api/post', :body => "hi, b", :session => @session_a.random_key, :receiver => 'b')
    get('/api/get', :session => @session_b.random_key)
    json(last_response.body)["status"].should == "ok"
     json(last_response.body)["message"]["body"].should == "hi, b"
     json(last_response.body)["message"]["author"].should == "a"
     json(last_response.body)["message"]["receiver"].should == "b"
     json(last_response.body)["message"]["channel"].should == nil

    get('/api/get', :session => @session_c.random_key)
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["message"].should == nil
  end

  should 'reject messages for not exist user' do
    post('/api/post', :body => "hi, nil", :session => @session_a.random_key, :receiver => 'niluser')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["errors"].should.include("ReceiverNotFound")
  end

  should 'can post or get with channel and receiver' do
    post('/api/post', :body => "hi, cool, b", :receiver => "b", :session => @session_a_cool.random_key)
    get('/api/get', :session => @session_b_cool.random_key)
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["message"]["body"].should == "hi, cool, b"
    json(last_response.body)["message"]["author"].should == "a"
    json(last_response.body)["message"]["receiver"].should == "b"
    json(last_response.body)["message"]["channel"].should == "cool"

    get('/api/get', :session => @session_b.random_key)
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["message"].should == nil
  end

  should 'comet with timeout' do
    # XXX: 0.1 sec is enough??
    lambda {
      timeout(0.1) {
        get('/api/get', :session => @session_a.random_key, :timeout => 10)
      }
    }.should.raise(Timeout::Error)
  end

  should 'can get sessions' do
    get('/api/sessions', :session => @session_a_cool.random_key)
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["sessions"].class.should == Array
    json(last_response.body)["sessions"].sort.should == %w{ a b c}.sort

    get('/api/sessions', :session => @session_a_hot.random_key)
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["sessions"].class.should == Array
    json(last_response.body)["sessions"].should == %w{ a }

    get('/api/sessions', :session => @session_a.random_key)
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["errors"].should.include("ChannelNotFound")

    get('/api/sessions', :session => @session_a_cool.random_key, :channel => "hot")
    json(last_response.body)["sessions"].should == %w{ a }
  end

  should 'can logout' do
    post('/api/logout', :session => @session_a.random_key)
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["session"]["user_name"].should == "a"

    get('/api/get', :session => @session_a.random_key)
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["errors"].should.include("InvalidSession")
  end

  should 'receive system message' do
    post('/api/login', :name => "a", :password => "a", :channel => 'cool')
    session_new_a = json(last_response.body)["session"]

    get('/api/get', :session => @session_b_cool.random_key)
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["message"]["body"].should == "logged in"
    json(last_response.body)["message"]["author"].should == "a"
    json(last_response.body)["message"]["receiver"].should == nil
    json(last_response.body)["message"]["channel"].should == "cool"
    json(last_response.body)["message"]["is_system"].should == true
    json(last_response.body)["sessions"].sort.should == %w{ a a b c }

    post('/api/logout', :session => session_new_a["random_key"])

    get('/api/get', :session => @session_b_cool.random_key)
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["message"]["body"].should == "logged out"
    json(last_response.body)["message"]["author"].should == "a"
    json(last_response.body)["message"]["receiver"].should == nil
    json(last_response.body)["message"]["channel"].should == "cool"
    json(last_response.body)["message"]["is_system"].should == true
    json(last_response.body)["sessions"].sort.should == %w{ a b c }

    post('/api/register', :name => "z", :password => "z")

    get('/api/get', :session => @session_b_cool.random_key)
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["message"]["body"].should == "registered"
    json(last_response.body)["message"]["author"].should == "z"
    json(last_response.body)["message"]["receiver"].should == nil
    json(last_response.body)["message"]["channel"].should == nil
    json(last_response.body)["message"]["is_system"].should == true
    json(last_response.body)["sessions"].sort.should == %w{ a b c }
  end

end
