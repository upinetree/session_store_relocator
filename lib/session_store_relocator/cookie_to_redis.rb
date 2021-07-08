require 'redis-session-store'

module SessionStoreRelocator
  class CookieToRedis < ActionDispatch::Session::CookieStore
    def initialize(app, options = {})
      super(app, options[:cookie_store])
      @redis_session_store = RedisSessionStore.new(app, options[:redis_session_store])
    end

    def prepare_session(*args)
      super.tap do
        req = args[0]
        req.env['rack.redis-session'] = @redis_session_store
      end
    end

    def destroy_session(*args)
      super.tap do
        @redis_session_store.send(:destroy_session, *args)
      end
    end

    def commit_session(*args)
      super.tap do
        @redis_session_store.send(:commit_session, *args)
      end
    end
  end
end
