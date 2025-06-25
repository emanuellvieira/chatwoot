# TODO: Phase out the custom ConnectionPool wrappers ($alfred / $velma),
# switch to plain Redis clients here and let Rails 7.1+ handle pooling
# via `pool:` in RedisCacheStore (see rack_attack initializer).

# Alfred
# Add here as you use it for more features
# Used for Round Robin, Conversation Emails & Online Presence
$alfred = ConnectionPool.new(size: 5, timeout: 1) do
  redis = Rails.env.test? ? MockRedis.new : Redis.new(Redis::Config.app)
  Redis::Namespace.new('alfred', redis: redis, warning: true)
end

# Velma : Determined protector
# used in rack attack
$velma = ConnectionPool.new(size: 5, timeout: 1) do
  config = Rails.env.test? ? MockRedis.new : Redis.new(Redis::Config.app)
  Redis::Namespace.new('velma', redis: config, warning: true)
end

# Configure Rails cache store to avoid redis-namespace blind passthrough issues
# This is needed for Rails 7.1+ compatibility with redis-namespace
if Rails.env.production?
  begin
    # Use a separate Redis connection for Rails cache to avoid namespace conflicts
    cache_redis = Redis.new(Redis::Config.app)
    Rails.application.config.cache_store = :redis_cache_store, {
      redis: cache_redis,
      pool: false, # Disable Rails internal pooling since we're using a direct connection
      expires_in: 1.day,
      namespace: 'chatwoot_cache'
    }
  rescue => e
    # Fallback to memory store if Redis is not available during build
    Rails.logger.warn "Could not configure Redis cache store: #{e.message}. Using memory store as fallback."
    Rails.application.config.cache_store = :memory_store
  end
end
