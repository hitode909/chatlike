# -*- coding: utf-8 -*-
require 'timeout'

class MainController < Controller
  def index
    @title = "Index"
    @repositories = Vcs::Repository.all
  end

  def register
    @title = "Register"
    @errors = []
    return unless request.post?

    begin
      s = SessionManager.register(request[:name], request[:password])
    rescue => e
      @errors = [e.message]
      return
    end
    session[:session_key] = s.random_key
    @redirect = request[:redirect] || '/'
    response.body = render_file('view/redirect.xhtml', :redirect => request[:redirect] || '/')
  end

  def login
    @errors = []
    return unless request.post?

    begin
      s = SessionManager.login(request[:name], request[:password])
    rescue => e
      @errors = [e.message]
      return
    end
    session[:session_key] = s.random_key
    response.body = render_file('view/redirect.xhtml', :redirect => request[:redirect] || '/')
  end

  def logout
    @errors = []
    return unless request.post? and @session

    begin
      s = SessionManager.logout(@session.random_key)
    rescue => e
      @errors = [e.message]
      return
    end
    session.delete(:session_key)
    response.body = render_file('view/redirect.xhtml', :redirect => request[:redirect] || '/')
  end
end

