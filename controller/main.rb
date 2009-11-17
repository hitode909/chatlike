# -*- coding: nil -*-
require 'timeout'

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
    session.post_system_message_to_channel("registered")
    {:session => session.to_hash}
  end

  def login
    return unless request.post? and request[:name] and request[:password]
    begin
      session = Messager.login(request[:name], request[:password], request[:channel])
    rescue(Messager::UserNotFound) => e
      return raised_error(e)
    end
    session.post_system_message_to_channel("logged in")
    {:session => session.to_hash}
  end

  def logout
    return unless request.post? and check_session
    @session.post_system_message_to_channel("logged out")
    @session.kill
    {:session => @session.to_hash}
  rescue => e
    raised_error(e)
  end

  def get
    return unless request.get? and check_session
    from = Time.now
    timeout_sec = request[:timeout] ? request[:timeout].to_f : nil rescue nil
    timeout_sec = 30 if timeout_sec and not (0..60).include?(timeout_sec)
    sleep_interval = 0.4

    begin
      timeout(timeout_sec || 30) do
        loop do
          message = @session.receive_message
          if message
            hash = {:message =>message.to_hash }
            if message.is_system and @session.channel
              hash[:sessions] = @session.channel.sessions.map{ |s| s.user.name }
            end
            return hash
          end
          raise Timeout::Error unless timeout_sec
          sleep sleep_interval
        end
      end
    rescue Timeout::Error
      return { }
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
    {:message => @session.post_message_to_channel(request[:body], option).to_hash}
  rescue => e
    raised_error(e)
  end

  def members
    return unless request.get? and check_session
    channel = (request[:channel] && Messager::Channel.find(:name => request[:channel])) || @session.channel || nil
    return raised_error(RuntimeError.new("ChannelNotFound")) unless channel
    return { :members => channel.sessions.map{ |s| s.user.name} }
  end
end
