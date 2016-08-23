class HTTP::Server
  class Context
    @response_end : (Bool | Nil) = nil

    def session
      @session ||= Warp::Sessions.new(self)
      @session.not_nil!
    end

    def response_end
      @response_end = true
    end
  end
end
