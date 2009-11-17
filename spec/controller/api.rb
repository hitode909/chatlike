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
    Messager.register('c', 'c')
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
    post('/api/login', :name => 'a', :password => 'a')
    token = json(last_response.body)["session"]["random_key"]

    post('/api/post', :session => token, :body => 'hello')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["post"]["author"].should == 'a'
    json(last_response.body)["post"]["body"].should == 'hello'
    json(last_response.body)["post"]["channel"].should == nil
    json(last_response.body)["post"]["receiver"].should == nil
  end

  should 'cannot post without body' do
    post('/api/login', :name => 'a', :password => 'a')
    token = json(last_response.body)["session"]["random_key"]

    post('/api/post', :session => token)
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
    post('/api/login', :name => 'a', :password => 'a')
    token_a = json(last_response.body)["session"]["random_key"]

    post('/api/login', :name => 'b', :password => 'b')
    token_b = json(last_response.body)["session"]["random_key"]

    post('/api/post', :body => "hello", :session => token_a)
    post('/api/post', :body => "world", :session => token_a)

    get('/api/get', :session => token_b)
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["post"]["body"].should == "hello"
    json(last_response.body)["post"]["author"].should == "a"
    json(last_response.body)["post"]["receiver"].should == nil
    json(last_response.body)["post"]["channel"].should == nil

    get('/api/get', :session => token_b)
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["post"]["body"].should == "world"

    get('/api/get', :session => token_b)
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["post"].should == nil
  end

  should 'can post or get with channel' do
    post('/api/login', :name => 'a', :password => 'a', :channel => "cool")
    session_a = json(last_response.body)["session"]

    post('/api/login', :name => 'b', :password => 'b', :channel => "cool")
    session_b = json(last_response.body)["session"]

    post('/api/login', :name => 'c', :password => 'c')
    session_c = json(last_response.body)["session"]

    post('/api/post', :body => "hi, cool", :session => session_a["random_key"])
    get('/api/get', :session => session_b["random_key"])
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["post"]["body"].should == "hi, cool"
    json(last_response.body)["post"]["author"].should == "a"
    json(last_response.body)["post"]["receiver"].should == nil
    json(last_response.body)["post"]["channel"].should == "cool"

    get('/api/get', :session => session_c["random_key"])
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["post"].should == nil
  end

  should 'can post or get with receiver' do
    post('/api/login', :name => 'a', :password => 'a')
    session_a = json(last_response.body)["session"]

    post('/api/login', :name => 'b', :password => 'b')
    session_b = json(last_response.body)["session"]

    post('/api/login', :name => 'c', :password => 'c')
    session_c = json(last_response.body)["session"]

    post('/api/post', :body => "hi, b", :session => session_a["random_key"], :receiver => 'b')
    get('/api/get', :session => session_b["random_key"])
    json(last_response.body)["status"].should == "ok"
     json(last_response.body)["post"]["body"].should == "hi, b"
     json(last_response.body)["post"]["author"].should == "a"
     json(last_response.body)["post"]["receiver"].should == "b"
     json(last_response.body)["post"]["channel"].should == nil

    get('/api/get', :session => session_c["random_key"])
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["post"].should == nil
  end

  should 'reject messages for not exist user' do
    post('/api/login', :name => 'a', :password => 'a')
    session_a = json(last_response.body)["session"]
    post('/api/post', :body => "hi, nil", :session => session_a["random_key"], :receiver => 'niluser')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["errors"].should.include("ReceiverNotFound")
  end

  should 'can post or get with channel and receiver' do
    post('/api/login', :name => 'a', :password => 'a', :channel => "cool")
    session_a_ch = json(last_response.body)["session"]

    post('/api/login', :name => 'b', :password => 'b', :channel => "cool")
    session_b_ch = json(last_response.body)["session"]

    post('/api/login', :name => 'b', :password => 'b')
    session_b = json(last_response.body)["session"]

    post('/api/post', :body => "hi, cool, b", :receiver => "b", :session => session_a_ch["random_key"])
    get('/api/get', :session => session_b_ch["random_key"])
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["post"]["body"].should == "hi, cool, b"
    json(last_response.body)["post"]["author"].should == "a"
    json(last_response.body)["post"]["receiver"].should == "b"
    json(last_response.body)["post"]["channel"].should == "cool"

    get('/api/get', :session => session_b["random_key"])
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["post"].should == nil
  end

  should 'comet with timeout' do
    require 'timeout'
    post('/api/login', :name => 'a', :password => 'a')
    session_a = json(last_response.body)["session"]

    # XXX: 0.1 sec is enough??
    lambda {
      timeout(0.1) {
        get('/api/get', :session => session_a["random_key"], :timeout => 10)
      }
    }.should.raise(Timeout::Error)
  end

  should 'can get members' do
    post('/api/login', :name => 'a', :password => 'a', :channel => "cool")
    session_a_cool = json(last_response.body)["session"]
    post('/api/login', :name => 'b', :password => 'b', :channel => "cool")
    session_b_cool = json(last_response.body)["session"]
    post('/api/login', :name => 'c', :password => 'c', :channel => "cool")
    session_c_cool = json(last_response.body)["session"]
    post('/api/login', :name => 'a', :password => 'a', :channel => "hot")
    session_a_hot = json(last_response.body)["session"]
    post('/api/login', :name => 'a', :password => 'a')
    session_a = json(last_response.body)["session"]

    get('/api/members', :session => session_a_cool["random_key"])
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["members"].class.should == Array
    json(last_response.body)["members"].sort.should == %w{ a b c}.sort

    get('/api/members', :session => session_a_hot["random_key"])
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["members"].class.should == Array
    json(last_response.body)["members"].should == %w{ a }

    get('/api/members', :session => session_a["random_key"])
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["errors"].should.include("ChannelNotFound")

    get('/api/members', :session => session_a_cool["random_key"], :channel => "hot")
    json(last_response.body)["members"].should == %w{ a }
  end

  should 'can logout' do
    post('/api/login', :name => 'a', :password => 'a')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    session_a = json(last_response.body)["session"]
    session_a["user_name"].should == "a"

    post('/api/logout', :session => session_a["random_key"])
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    session_a["user_name"].should == "a"

    get('/api/get', :session => session_a["random_key"])
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["errors"].should.include("InvalidSession")
  end

end
