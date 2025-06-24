# frozen_string_literal: true

# Enterprise Whitelabel Configuration
# Força o modo enterprise e remove dependências do Chatwoot original

Rails.application.config.after_initialize do
  # Força o modo enterprise
  ENV['CHATWOOT_ENTERPRISE'] = 'true'
  
  # Remove branding do Chatwoot
  ENV['DISABLE_BRANDING'] = 'true'
  
  # Log das configurações enterprise
  Rails.logger.info '🚀 Enterprise Whitelabel Mode Activated!'
  Rails.logger.info '   - All enterprise features enabled'
  Rails.logger.info '   - Chatwoot branding disabled'
  Rails.logger.info '   - Independent installation'
  
  # Configurações enterprise forçadas
  Rails.application.config.enterprise_mode = true
  Rails.application.config.disable_branding = true
  
  # Remove qualquer verificação de licença
  if defined?(ChatwootApp)
    ChatwootApp.class_eval do
      def self.enterprise?
        true
      end
      
      def self.enterprise_edition?
        true
      end
    end
  end
end 