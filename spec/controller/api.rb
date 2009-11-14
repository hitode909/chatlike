require File.dirname(__FILE__) + '/../spec_helper'
require 'ramaze'
require 'ramaze/spec/bacon'
require __DIR__('../../app')

describe MainController do
  behaves_like :rack_test

  before do
    delete_test_db
  end

  should 'can register' do
    post('/api/register', :name => 'a', :password => 'b')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["data"].length.should > 32
  end

  should 'cannot register dupricate user' do
    post('/api/register', :name => 'b', :password => 'b')
    json(last_response.body)["status"].should == "ok"
    post('/api/register', :name => 'b', :password => 'b')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["error"].should.include("DupricateUser")
  end

  should 'can login' do
    post('/api/login', :name => 'a', :password => 'b')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ok"
    json(last_response.body)["data"].length.should > 32
  end

  should 'cannot login with invalid user' do
    post('/api/login', :name => 'a', :password => 'foobar')
    last_response.status.should == 200
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["error"].should.include("UserNotFound")
  end
end
