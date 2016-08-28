class HTTP::Server
  class Context
    property response_end : Bool = false

    def session
      @session ||= Warp::Sessions.new(self)
      @session.not_nil!
    end

  end
end
