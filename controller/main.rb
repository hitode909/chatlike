# -*- coding: nil -*-
class MainController < Controller
  def index
    @title = "Chat"
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
    from = Time.now
    timeout = request[:timeout].to_i rescue nil
    loop do
      m = @session.receive_message
      if m
        return data(m)
      else
        if timeout and from + timeout > Time.now
          sleep 0.5
          redo
        else
          return { }
        end
      end
    end
  rescue => e
    raised_error(e)
  end

  def post
    return unless request.post? and check_session and check_request(:body)
    option = { }
    if request[:receiver]
      u = Messager::User.find(:name => request[:receiver])
      return raised_error(raise "ReceiverNotFound") unless u
      option[:receiver] = u
    end
    data(@session.post_message_to_channel(request[:body], option))
  rescue => e
    raised_error(e)
  end
end
