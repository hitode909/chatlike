# -*- coding: nil -*-
class MainController < Controller
  def index
    @title = "Welcome to Ramaze!"
  end
end

class ApiController < JsonController
  def register
    return unless request.post? and request[:name] and request[:password]
    begin
      session = Messager.register(request[:name], request[:password])
    rescue(Messager::DupricateUser) => e
      return raised_error(e)
    end
    session.random_key
  end

  def login
    return unless request.post? and request[:name] and request[:password]
    begin
      session = Messager.login(request[:name], request[:password])
    rescue(Messager::UserNotFound) => e
      return raised_error(e)
    end
    session.random_key
  end

  def get
    return unless request[:key] and Session.check request[:key]
    sleep 3
    MessageQueue.get(request[:key])
  end

  def post
    return unless request.post? and check_session and check_request(:body)
    @session.create_message(:body)
  rescue => e
    raised_error(e)
  end
end
