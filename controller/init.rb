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
        :status => "ok"
      }
    end
    s.to_hash.to_json
  }
end


# Here go your requires for subclasses of Controller:
require __DIR__('main')
