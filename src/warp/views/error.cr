module Warp::Web::View
  # View class
  class Error < Warp::View
    # def initialize(@code = 500, @message : String | Nil = "")
    # end
    def render
      html do
        head do
          title("Error #{outbox[:status_code]}")
        end
        body do
          div outbox[:status_code]?
          div outbox[:exception_message]?
        end
      end
    end
  end
end
