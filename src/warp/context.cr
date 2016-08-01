class HTTP::Server
  class Context
    def session
      @session ||= Warp::Sessions.new(self)
      @session.not_nil!
    end
  end
end
