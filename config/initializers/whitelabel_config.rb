# frozen_string_literal: true

# Whitelabel Configuration Loader
# Carrega as configurações do whitelabel enterprise

require 'yaml'

# Carrega configurações do whitelabel
whitelabel_config_path = Rails.root.join('config', 'whitelabel.yml')

if File.exist?(whitelabel_config_path)
  WHITELABEL_CONFIG = YAML.load_file(whitelabel_config_path)['whitelabel']
else
  # Configurações padrão se o arquivo não existir
  WHITELABEL_CONFIG = {
    'company' => {
      'name' => 'Enterprise Chatwoot',
      'website' => 'https://your-company.com',
      'support_email' => 'support@your-company.com'
    },
    'app' => {
      'name' => 'Enterprise Chatwoot',
      'version' => '2.0.0-enterprise-whitelabel'
    },
    'features' => {
      'enterprise' => true,
      'premium' => true,
      'branding_disabled' => true
    }
  }
end

# Disponibiliza as configurações globalmente
Rails.application.config.whitelabel = WHITELABEL_CONFIG

# Log das configurações carregadas
Rails.logger.info "🎨 Whitelabel config loaded: #{WHITELABEL_CONFIG['app']['name']} v#{WHITELABEL_CONFIG['app']['version']}" 