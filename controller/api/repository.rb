module Api
  class RepositoryController < JsonController
    def checkout
      return unless request.post? and check_session and check_repository(request[:repository])
      @session.post_json_message({
          :type => 'checkout',
          :repository => @repository.to_hash
        },
        :receiver => @session.user
        )
      { :status => 'ok' }
    end

    def fork
      return unless request.post? and check_session and check_repository(request[:repository])
      new_repository = @repository.fork(@session.user)
      @session.post_json_message({
          :type => 'checkout',
          :repository => new_repository.to_hash
        },
        :receiver => @session.user
        )
      { :status => 'ok',
        :repository => new_repository.to_hash
      }
    rescue => e
      raised_error(e)
    end

    def delete
      return unless request.post? and check_session and check_repository(request[:repository])
      raise "NotYourRepository" unless @repository.author == @session.user
      new_repository = @repository.destroy
      @session.post_json_message({
          :type => 'delete',
          :repository => new_repository.to_hash
        },
        :receiver => @session.user
        )
      { :status => 'ok',
        :repository => new_repository.to_hash
      }
     rescue => e
       raised_error(e)
    end
  end
end
