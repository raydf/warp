require "secure_random"

module Warp
  # Kemal's default session is in-memory only and holds simple String values only.
  # The client-side cookie stores a random ID.
  #
  # Kemal handlers can access the session like so:
  #
  #   get("/") do |env|
  #     env.session["abc"] = "xyz"
  #     uid = env.session["user_id"]?
  #   end
  #
  # Note that only String values are allowed.
  #
  # Sessions are pruned hourly after 48 hours of inactivity.
  class Sessions
    NAME = "SessionId"

    TTL = 24.hours

    # In-memory, ephemeral datastore only.
    #
    # Implementing Redis or Memcached as a datastore
    # is left as an exercise to another reader.
    #
    # Note that the only thing we store on the client-side
    # is an opaque, random String.  If we actually wanted to
    # store any data, we'd need to implement encryption, key
    # rotation, tamper-detection and that whole iceberg.
    STORE = Hash(String, Session).new

    class Session
      getter! id : String
      property! last_access_at : Int64

      def initialize(@id)
        @last_access_at = Time.new.epoch_ms
        @store = Hash(Symbol, JSON::Type).new
      end

      def [](key : Symbol)
        @last_access_at = Time.now.epoch_ms
        @store[key]
      end

      def []?(key : Symbol)
        @last_access_at = Time.now.epoch_ms
        @store[key]?
      end

      def []=(key : Symbol, value : JSON::Type)
        @last_access_at = Time.now.epoch_ms
        @store[key] = value
      end

      def delete(key : Symbol)
        @last_access_at = Time.now.epoch_ms
        @store.delete(key)
      end
    end

    getter! id : String

    def initialize(ctx : HTTP::Server::Context)
      id = ctx.request.cookies[NAME]?.try &.value
      if id && id.size == 32
        # valid
      else
        # new or invalid
        id = SecureRandom.hex
      end

      ctx.response.cookies[NAME] = id
      @id = id
    end

    def []=(key : Symbol, value : JSON::Type)
      store = STORE[id]? || begin
        STORE[id] = Session.new(id)
      end
      store[key] = value
    end

    def [](key : Symbol)
      STORE[@id][key]
    end

    def []?(key : Symbol)
      STORE[@id]?.try &.[key]?
    end

    def delete(key : Symbol)
      STORE[@id]?.try &.delete(key)
    end

    def self.prune!(before = (Time.now - Warp::Sessions::TTL).epoch_ms)
      Warp::Sessions::STORE.delete_if { |id, entry| entry.last_access_at < before }
      nil
    end

    # This is an hourly job to prune the in-memory hash of any
    # sessions which have expired due to inactivity, otherwise
    # we'll have a slow memory leak and possible DDoS vector.
    def self.run_reaper!
      spawn do
        loop do
          prune!
          sleep 3600
        end
      end
    end
  end
end
