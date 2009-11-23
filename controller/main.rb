# -*- coding: utf-8 -*-
require 'timeout'

class MainController < Controller
  def index
    @title = "Chat"
  end
end

class RepositoryController < Controller
  def index(path)
    @repos = Vcs::Repository.find(:path => path)
  end
end
