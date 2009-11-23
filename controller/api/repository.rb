module Api
  class RepositoryController < JsonController
    def checkout
      return unless request.post? and check_session and check_repository(request[:repository])
      @session.post_message(
        {
          :type => 'checkout',
          :repository => @repository.to_hash
        }.to_json)
      { :status => 'ok' }
    end
  end
end
