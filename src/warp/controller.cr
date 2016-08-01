require "./handlers"

module Warp

  abstract class Controller < Toro::Router
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

    macro render(template)
      header "Content-Type", "text/html"
      write {{template}}.to_s
    end

    # Overriding call without segment
    def self.call(context : HTTP::Server::Context)
      new(context).main_call
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
          render Warp::Web::View::Error.new(context.response.status_code, ex.message)
        end
        return
      end

      if (context.response.status_code >= 400) && (context.response.status_code < 600)
        if json?
          json({error: context.response.status_code})
        else
          render Warp::Web::View::Error.new(context.response.status_code)
        end
      end

      # elapsed = Time.now - time
      # elapsed_text = elapsed_text(elapsed)
      # pp "#{time} #{context.response.status_code} #{context.request.method} #{context.request.resource} - #{elapsed_text}\n"
    end

    private def elapsed_text(elapsed)
      minutes = elapsed.total_minutes
      return "#{minutes.round(2)}m" if minutes >= 1

      seconds = elapsed.total_seconds
      return "#{seconds.round(2)}s" if seconds >= 1

      millis = elapsed.total_milliseconds
      return "#{millis.round(2)}ms" if millis >= 1

      "#{(millis * 1000).round(2)}µs"
    end

    abstract def routes
  end
end
