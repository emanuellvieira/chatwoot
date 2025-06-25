namespace :onboarding do
  desc "Diagnose and fix onboarding issues"
  task diagnose: :environment do
    puts "🔍 Diagnosing onboarding issues..."
    
    begin
      # Check Redis connection
      redis = Redis.new(Redis::Config.app)
      ping_result = redis.ping
      puts "✅ Redis connection: #{ping_result}"
      
      # Check onboarding key
      onboarding_key = Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING
      current_value = Redis::Alfred.get(onboarding_key)
      puts "📋 Onboarding key value: #{current_value.inspect}"
      
      # Check if any users exist
      user_count = User.count
      puts "👥 Total users: #{user_count}"
      
      # Check if any accounts exist
      account_count = Account.count
      puts "🏢 Total accounts: #{account_count}"
      
      # Check environment
      puts "🌍 Environment: #{Rails.env}"
      puts "🔧 Installation env: #{ENV['INSTALLATION_ENV']}"
      
      # Determine what should happen
      if current_value.nil? && user_count == 0
        puts "✅ Onboarding should be shown (no users, no key set)"
      elsif current_value.nil? && user_count > 0
        puts "⚠️  Onboarding key is nil but users exist - this might be a problem"
      elsif current_value.present? && user_count == 0
        puts "❌ Onboarding key is set but no users - onboarding is blocked"
      else
        puts "✅ System appears to be properly configured"
      end
      
    rescue => e
      puts "❌ Error during diagnosis: #{e.message}"
    end
  end

  desc "Reset onboarding to show setup page"
  task reset: :environment do
    puts "🔄 Resetting onboarding state..."
    
    begin
      onboarding_key = Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING
      
      # Delete the onboarding key
      Redis::Alfred.delete(onboarding_key)
      puts "✅ Onboarding key deleted"
      
      # Clear any cached configurations
      GlobalConfig.clear_cache
      puts "✅ Global config cache cleared"
      
      puts "🎉 Onboarding has been reset. Access your app to see the setup page."
      
    rescue => e
      puts "❌ Error resetting onboarding: #{e.message}"
    end
  end

  desc "Force enable onboarding (for new installations)"
  task enable: :environment do
    puts "🔧 Enabling onboarding for new installation..."
    
    begin
      onboarding_key = Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING
      
      # Ensure the key is nil (not set)
      Redis::Alfred.delete(onboarding_key)
      puts "✅ Onboarding key cleared (set to nil)"
      
      # Clear any cached configurations
      GlobalConfig.clear_cache
      puts "✅ Global config cache cleared"
      
      puts "🎉 Onboarding is now enabled for new installations."
      
    rescue => e
      puts "❌ Error enabling onboarding: #{e.message}"
    end
  end

  desc "Check if onboarding should be shown"
  task check: :environment do
    puts "🔍 Checking if onboarding should be shown..."
    
    begin
      onboarding_key = Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING
      current_value = Redis::Alfred.get(onboarding_key)
      user_count = User.count
      
      should_show = current_value.nil? && user_count == 0
      
      puts "📊 Results:"
      puts "  - Onboarding key value: #{current_value.inspect}"
      puts "  - User count: #{user_count}"
      puts "  - Should show onboarding: #{should_show ? 'YES' : 'NO'}"
      
      if should_show
        puts "✅ Onboarding should be displayed"
      else
        puts "❌ Onboarding will not be displayed"
        if current_value.present?
          puts "   Reason: Onboarding key is set to #{current_value}"
        end
        if user_count > 0
          puts "   Reason: Users already exist (#{user_count} users)"
        end
      end
      
    rescue => e
      puts "❌ Error checking onboarding: #{e.message}"
    end
  end
end 