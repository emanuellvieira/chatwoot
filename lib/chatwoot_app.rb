# frozen_string_literal: true

# ChatwootApp Enterprise Whitelabel
# Versão modificada para funcionar independentemente do Chatwoot original

class ChatwootApp
  # Sempre retorna true para enterprise
  def self.enterprise?
    true
  end

  # Sempre retorna true para enterprise edition
  def self.enterprise_edition?
    true
  end

  # Sempre retorna true para premium features
  def self.premium?
    true
  end

  # Remove branding do Chatwoot
  def self.branding_disabled?
    true
  end

  # Versão customizada
  def self.version
    '2.0.0-enterprise-whitelabel'
  end

  # Nome customizado
  def self.app_name
    'Enterprise Chatwoot'
  end

  # Remove dependências do Chatwoot original
  def self.contact_support_team_enabled?
    false
  end

  # Força modo enterprise
  def self.enterprise_mode?
    true
  end

  # Configurações enterprise
  def self.enterprise_config
    {
      'enterprise' => true,
      'premium' => true,
      'branding_disabled' => true,
      'whitelabel' => true,
      'independent' => true
    }
  end
end
