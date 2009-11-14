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
    d = json(last_response.body)
    d["status"].should == 'ok'
    d["data"].length == 32
  end

  should 'cannot register dupricate user' do
    post('/api/register', :name => 'b', :password => 'b')
    json(last_response.body)["status"].should == "ok"
    post('/api/register', :name => 'b', :password => 'b')
    json(last_response.body)["status"].should == "ng"
    json(last_response.body)["error"].should.include("dupricate user name")
  end
end
