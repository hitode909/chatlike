module Api
  class SessionController < JsonController
    def register
      return unless request.post? and request[:name] and request[:password]
      begin
        session = SessionManager.register(request[:name], request[:password], request[:channel])
      rescue(SessionManager::DupricateUser) => e
        return raised_error(e)
      end
      {:session => session.to_hash}
    end

    def login
      return unless request.post? and request[:name] and request[:password]
      begin
        session = SessionManager.login(request[:name], request[:password], request[:channel])
      rescue(SessionManager::UserNotFound) => e
        return raised_error(e)
      end
      {:session => session.to_hash}
    end

    def logout
      return unless request.post? and check_session
      @session.kill
      {:session => @session.to_hash}
    rescue => e
      raised_error(e)
    end

    def get
      return unless request.get? and check_session
      from = Time.now
      timeout_sec = request[:timeout] ? request[:timeout].to_f : nil rescue nil
      timeout_sec = 60 if timeout_sec and not (0..60).include?(timeout_sec)

      gc_invalid_sessions
      if @session.channel and @session.channel.sessions.count < 6
        last_gcd = Time.now
      end

      begin
        timeout(timeout_sec || 60) do
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
            sleep 0.2
            if last_gcd and last_gcd + 10 < Time.now
              gc_invalid_sessions
              last_gcd = Time.now
            end
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
        u = SessionManager::User.find(:name => request[:receiver])
        return raised_error(raise "ReceiverNotFound") unless u
        option[:receiver] = u
      end
      {:message => @session.post_message_to_channel(request[:body], option).to_hash}
    rescue => e
      raised_error(e)
    end

    def sessions
      return unless request.get? and check_session
      channel = (request[:channel] && SessionManager::Channel.find(:name => request[:channel])) || @session.channel || nil
      return raised_error(RuntimeError.new("ChannelNotFound")) unless channel
      return { :sessions => channel.sessions.map{ |s| s.user.name} }
    end

    private
    def gc_invalid_sessions
      if @session.channel
        @session.channel.refresh.invalid_sessions.each { |s|
          s.kill
        }
      end
    end
  end

end
