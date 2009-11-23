require 'sequel/extensions/inflector'

class Controller < Ramaze::Controller
  layout :default
  helper :xhtml
  engine :Etanni

  before_all do
    unless @user or @session
      session_key = request[:session] || session[:session_key]
      @session = SessionManager.session(session_key) if session_key
    end
  end
end

require 'json'
class JsonController < Controller
  provide(:html, :type => 'application/json'){|a,s|
    s[:status] = "ok" unless s.has_key? :status
    s.to_json
  }

  private

  def check_request(key)
    raise "#{key.to_s.camelize}Required" unless request[key]
    true
  end

  def check_session
    raise "SessionRequired" unless request[:session]
    @session = SessionManager.session(request[:session])
    raise "InvalidSession" unless @session
    @session.update_expire
    @session.save
    true
  end
  def raised_error(*errors)
    { :status => "ng",
      :errors => errors.map{ |e| e.message.split("::").last}
    }
  end

  def data(object)
    { :status => "ok",
      :data => object.to_hash
    }
  end
end


# Here go your requires for subclasses of Controller:
require __DIR__('main')
require __DIR__('api/session')
