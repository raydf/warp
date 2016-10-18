module Warp::Web::View
  # View class
  class Error(T) < Warp::View(T)
    def render
      html do
        head do
          title("Error #{props[:status_code]}")
        end
        body do
          div props[:status_code]?
          div props[:exception_message]?
        end
      end
    end
  end
end
