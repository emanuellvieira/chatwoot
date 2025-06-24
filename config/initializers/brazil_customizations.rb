# frozen_string_literal: true

# Inicializador para features enterprise do Chatwoot
Rails.application.configure do
  # Adiciona pasta de customizações ao autoload path
  config.autoload_paths += %W[
    #{Rails.root}/app/brazil_customizations
    #{Rails.root}/app/brazil_customizations/controllers
    #{Rails.root}/app/brazil_customizations/services
    #{Rails.root}/app/brazil_customizations/models
    #{Rails.root}/app/brazil_customizations/jobs
  ]
end

# Carrega configurações após inicialização
Rails.application.config.after_initialize do
  # Log das features enterprise ativadas
  Rails.logger.info '🚀 Enterprise Features loaded successfully!'
  
  begin
    if defined?(BrazilCustomizations::Config)
      Rails.logger.info "   Enterprise features: #{BrazilCustomizations::Config::ENTERPRISE_FEATURES.join(', ')}"
    else
      Rails.logger.info "   Using default settings"
    end
  rescue StandardError => e
    Rails.logger.error "❌ Error loading Enterprise Features: #{e.message}"
  end
end 