# frozen_string_literal: true

# Configuração para features enterprise do Chatwoot
class Config
  # Features enterprise ativadas
  ENTERPRISE_FEATURES = %w[
    disable_branding
    audit_logs
    sla
    custom_roles
    captain_integration
    help_center_embedding_search
  ].freeze
  
  class << self
    # Verifica se uma feature enterprise está ativada
    def enterprise_feature_enabled?(feature_name)
      ENTERPRISE_FEATURES.include?(feature_name.to_s)
    end
  end
end

# Alias para compatibilidade com código existente
BrazilCustomizations = Module.new
BrazilCustomizations::Config = Config 