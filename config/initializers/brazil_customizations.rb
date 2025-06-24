# frozen_string_literal: true

# Inicializador para customizações brasileiras do Chatwoot Fork
Rails.application.configure do
  # Adiciona pasta de customizações brasileiras ao autoload path
  config.autoload_paths += %W[
    #{Rails.root}/app/brazil_customizations
    #{Rails.root}/app/brazil_customizations/controllers
    #{Rails.root}/app/brazil_customizations/services
    #{Rails.root}/app/brazil_customizations/models
    #{Rails.root}/app/brazil_customizations/jobs
  ]
  
  # Configurações específicas para o Brasil
  # Usa valores padrão durante o build
  config.time_zone = 'America/Sao_Paulo'
  config.i18n.default_locale = :'pt-BR'
  config.i18n.available_locales = [:'pt-BR', :en]
  
  # Força encoding UTF-8 para caracteres brasileiros
  config.encoding = 'utf-8'
end

# Carrega configurações após inicialização
Rails.application.config.after_initialize do
  # Log das customizações ativadas
  Rails.logger.info '🇧🇷 Brazil Customizations loaded successfully!'
  
  begin
    if defined?(BrazilCustomizations::Config)
      Rails.logger.info "   Timezone: #{BrazilCustomizations::Config::TIMEZONE}"
      Rails.logger.info "   Locale: #{BrazilCustomizations::Config::LOCALE}"
      Rails.logger.info "   Enterprise features: #{BrazilCustomizations::Config::ENTERPRISE_FEATURES.join(', ')}"
      
      # Configura horário comercial brasileiro como padrão
      if defined?(WorkingHours)
        WorkingHours::Config.working_hours = BrazilCustomizations::Config::BUSINESS_HOURS
        WorkingHours::Config.time_zone = BrazilCustomizations::Config::TIMEZONE
      end
    else
      Rails.logger.info "   Using default Brazilian settings"
    end
  rescue StandardError => e
    Rails.logger.error "❌ Error loading Brazil Customizations: #{e.message}"
  end
end 