module Warp
  class Handler < HTTP::Handler
    def initialize (@controller : Warp::Controller.class)
    end

    def call(context)
      @controller.new(context).call
    end
  end

  class StaticFileHandler < HTTP::StaticFileHandler
    def call(context)
      return call_next(context) if context.request.path.not_nil! == "/"
      super
    end
  end
end
