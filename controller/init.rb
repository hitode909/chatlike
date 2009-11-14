# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

class Controller < Ramaze::Controller
  layout :default
  helper :xhtml
  engine :Etanni
end

require 'json'
class JsonController < Controller
  provide(:html, :type => 'application/json'){|a,s|
    unless s.respond_to? :to_hash
      s = {
        :data => s,
      }
    end
    s[:status] = "ok" unless s.has_key? :status
    s.to_hash.to_json
  }

  private
  def raised_error(*errors)
    { :status => "ng",
      :error => errors.map{ |e| e.to_s.split("::").last}
    }
  end

  def error(*messages)
    { :status => "ng",
      :error => messages
    }
  end
end


# Here go your requires for subclasses of Controller:
require __DIR__('main')
