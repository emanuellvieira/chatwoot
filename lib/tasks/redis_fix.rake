namespace :redis do
  desc "Fix Redis onboarding issues and clear problematic keys"
  task fix_onboarding: :environment do
    puts "Checking Redis onboarding status..."
    
    # Check if onboarding key exists
    onboarding_key = Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING
    current_value = Redis::Alfred.get(onboarding_key)
    
    puts "Current onboarding key value: #{current_value}"
    
    if current_value.nil?
      puts "Onboarding key is not set. Setting it to true..."
      Redis::Alfred.set(onboarding_key, true)
      puts "Onboarding key has been set to true"
    else
      puts "Onboarding key is already set to: #{current_value}"
    end
    
    # Clear any problematic cache keys that might be causing issues
    puts "Clearing GlobalConfig cache..."
    GlobalConfig.clear_cache
    
    puts "Redis onboarding fix completed!"
  end

  desc "Reset onboarding state (use with caution)"
  task reset_onboarding: :environment do
    puts "Resetting onboarding state..."
    
    onboarding_key = Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING
    Redis::Alfred.delete(onboarding_key)
    
    puts "Onboarding state has been reset. You can now access the onboarding page again."
  end

  desc "Check Redis connection and configuration"
  task check: :environment do
    puts "Checking Redis connection..."
    
    begin
      # Test basic Redis connection
      redis = Redis.new(Redis::Config.app)
      ping_result = redis.ping
      puts "Redis ping result: #{ping_result}"
      
      # Test Alfred connection
      alfred_test = Redis::Alfred.get('test_key')
      puts "Alfred connection test: #{alfred_test.nil? ? 'OK' : 'Issue detected'}"
      
      # Check onboarding key
      onboarding_key = Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING
      onboarding_value = Redis::Alfred.get(onboarding_key)
      puts "Onboarding key value: #{onboarding_value}"
      
      puts "Redis connection check completed successfully!"
      
    rescue => e
      puts "Redis connection error: #{e.message}"
      puts "Please check your Redis configuration and ensure Redis is running."
    end
  end
end 