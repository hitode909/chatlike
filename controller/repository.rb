class RepositoryController < Controller
  def index(path)
    @repos = Vcs::Repository.find(:path => path)
  end
end
