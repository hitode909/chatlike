class RepositoryController < Controller
  def index(author, repository)
    path = [author, repository].join('/')
    @repos = Vcs::Repository.find(:path => path)
    unless @repos
      respond 'not found', 404
    end
  end
end
