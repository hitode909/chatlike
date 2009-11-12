# -*- coding: nil -*-
class MainController < Controller
  def index
    @title = "Welcome to Ramaze!"
  end
end

module Api
  class LoginController < JsonController
    def controller
      return unless request.post? and request[:name] and request[:password]
      Session.join request[:name], request[:password]
    end
  end

end

class ApiController < JsonController
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
