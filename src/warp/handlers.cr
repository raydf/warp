module Warp
  class Handler
    include HTTP::Handler
    
    def initialize(@controller : Warp::Controller.class)
    end

    def call(context)
      @controller.new(context).main_call
    end
  end

  class StaticFileHandler < HTTP::StaticFileHandler
    def call(context)
      return call_next(context) if context.request.path.not_nil! == "/"
      super 
    end
  end
end
