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
    rescue(Messager::DupricateUser)
      error("dupricate user name")
    else
      session.random_key
    end
  end

  def get
    return unless request[:key] and Session.check request[:key]
    sleep 3
    MessageQueue.get(request[:key])
  end

  def post
    "posted #{request[:data]}"
    MessageQueue.post(request[:key], request[:data])
  end
end
