module Warp::Web::View
  # View class
  class Error < Warp::View
    # def initialize(@code = 500, @message : String | Nil = "")
    # end
    
    def render
      html do
        head do
          title("Error #{inbox[:status_code]}")
        end
        body do
          div inbox[:status_code]?
          div inbox[:exception_message]?
        end
      end
    end
  end
end
