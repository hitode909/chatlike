class RepositoryController < Controller
  layout{|action, ext| "default" if action != "embed"}

  def index(author, repository)
    path = [author, repository].join('/')
    @repos = Vcs::Repository.find(:path => path)
    unless @repos
      respond 'not found', 404
    end
  end

  def embed(author, repository, *rest)
    path = [author, repository].join('/')
    @repository = Vcs::Repository.find(:path => path)
    unless @repository
      respond 'not repos', 404
    end
    path = [''].concat(rest).join('/')
    @entity = @repository.file_at(path)
    respond "no ent(#{path})", 404 unless @entity
  end

end
