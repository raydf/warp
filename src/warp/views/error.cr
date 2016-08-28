module Warp::Web::View
  # View class
  class Error < Warp::View
    def initialize(@code = 500, @message : String | Nil = "")
    end
    
    def render
      html do
        head do
          title("Error #{@code}")
        end
        body do
          div(@code)
          div(@message)
        end
      end
    end
  end
end
