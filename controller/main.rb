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
      session = Messager.register(request[:name], request[:password], request[:channel])
    rescue(Messager::DupricateUser) => e
      return raised_error(e)
    end
    data(session)
  end

  def login
    return unless request.post? and request[:name] and request[:password]
    begin
      session = Messager.login(request[:name], request[:password], request[:channel])
    rescue(Messager::UserNotFound) => e
      return raised_error(e)
    end
    data(session)
  end

  def get
    return unless request.get? and check_session
    m = @session.receive_message
    m ? data(m) : { }
  rescue => e
    raised_error(e)
  end

  def post
    return unless request.post? and check_session and check_request(:body)
    data(@session.post_message_to_channel(request[:body]))
  rescue => e
    raised_error(e)
  end
end
