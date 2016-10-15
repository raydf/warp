require "./handlers"

module Warp
  abstract class Controller < Toro::Router
    property outbox = {} of Symbol => Warp::Type
    property params = Params.new

    def self.run(port = 8080)
      server = HTTP::Server.new(port, [
        HTTP::ErrorHandler.new,
        Warp::StaticFileHandler.new("./public/"),
        Warp::Handler.new(self),
      ])

      Warp::Sessions.run_reaper!

      Signal::INT.trap do
        server.close
        exit
      end

      puts "#{name} - Listening on port #{port}"
      server.listen
    end

    def json?
      context.try &.request.headers.includes_word?("Accept", "json")
    end

    # Wrapping the first call with default error handling
    def main_call
      time = Time.now

      begin
        call
      rescue ex
        status 500
        if json?
          json({error: ex.message})
        else
          render Warp::Web::View::Error, {
            :status_code => context.response.status_code,
            :exception_message => ex.message
          }
        end
        return
      end

      if (context.response.status_code >= 400) && (context.response.status_code < 600) && (!context.response_end)
        if json?
          json({error: context.response.status_code})
        else
          # props[:status_code] = context.response.status_code
          render Warp::Web::View::Error, {
            :status_code => context.response.status_code
          }
        end
      end

      # elapsed = Time.now - time
      # elapsed_text = elapsed_text(elapsed)
      # pp "#{time} #{context.response.status_code} #{context.request.method} #{context.request.resource} - #{elapsed_text}\n"
    end

    macro render(template, outbox)
      header "Content-Type", "text/html"
      # view = {{template}}.new({{outbox}}, Warp::View::Params.new(@params.query, @params.form)) # (inbox[:process_kind]? || "")
      view = {{template}}.new({{outbox}}) # (inbox[:process_kind]? || "")
      # view.outbox = @outbox
      view.render()
      write view.to_s
    end

    abstract def routes

    def get(&block)
      @params.query = HTTP::Params.parse(context.request.query || "")
      root { status 200; yield } if get?
    end

    def post(&block)
      @params.form = HTTP::Params.parse(context.request.body || "")
      root { status 200; yield } if post?
    end

    class Params
      property query = HTTP::Params.new({} of String => Array(String))
      property form = HTTP::Params.new({} of String => Array(String))
    end
  end
end
