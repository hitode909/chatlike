class RepositoryController < Controller
  def index(*path)
    path = path.join('/')
    @repos = Vcs::Repository.find(:path => path)
    unless @repos
      respond 'not found', 404
    end
  end
end
