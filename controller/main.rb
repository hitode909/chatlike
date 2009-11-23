# -*- coding: utf-8 -*-
require 'timeout'

class MainController < Controller
  def index
    @title = "Chat"
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
    session[:user_key] = s.user.random_key
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
    session[:user_key] = s.user.random_key
    response.body = render_file('view/redirect.xhtml', :redirect => request[:redirect] || '/')
  end

  def logout
    @errors = []
    return unless request.post? and @user and @session

    begin
      s = SessionManager.logout(@session.random_key)
    rescue => e
      @errors = [e.message]
      return
    end
    session.delete(:session_key)
    session.delete(:user_key)
    response.body = render_file('view/redirect.xhtml', :redirect => request[:redirect] || '/')
  end
end

class RepositoryController < Controller
  def index(path)
    @repos = Vcs::Repository.find(:path => path)
  end
end
