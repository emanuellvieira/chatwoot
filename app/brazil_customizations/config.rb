# frozen_string_literal: true

# Configuração de localização brasileira para o Chatwoot
class Config
  # Configurações de localização
  TIMEZONE = 'America/Sao_Paulo'
  LOCALE = 'pt-BR'
  CURRENCY = 'BRL'
  
  # Configurações de horário comercial brasileiro padrão
  BUSINESS_HOURS = {
    weekdays: { start: '08:00', end: '18:00' },
    saturday: { start: '08:00', end: '12:00' },
    sunday: :closed,
    timezone: TIMEZONE
  }.freeze
  
  # Configurações de telefone brasileiro
  PHONE_CONFIG = {
    country_code: '+55',
    number_validation: /\A\+55\d{2}9?\d{8}\z/,
    formatting: lambda { |number|
      # Formatar número brasileiro: +55 (11) 99999-9999
      clean = number.gsub(/\D/, '')
      return number unless clean.match?(/\A55\d{10,11}\z/)
      
      area_code = clean[2..3]
      if clean.length == 13 # Celular com 9
        "#{clean[0..1]} (#{area_code}) #{clean[4]}#{clean[5..8]}-#{clean[9..12]}"
      else # Fixo ou celular antigo
        "#{clean[0..1]} (#{area_code}) #{clean[4..7]}-#{clean[8..11]}"
      end
    }
  }.freeze
  
  # Features enterprise ativadas (mantidas do original)
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
    
    # Retorna configuração de horário comercial para um dia específico
    def business_hours_for(day)
      case day.downcase.to_sym
      when :sunday
        nil
      when :saturday
        BUSINESS_HOURS[:saturday]
      else
        BUSINESS_HOURS[:weekdays]
      end
    end
    
    # Verifica se está dentro do horário comercial
    def within_business_hours?(time = Time.current)
      return false unless time
      
      time = time.in_time_zone(TIMEZONE)
      day_config = business_hours_for(time.strftime('%A'))
      
      return false if day_config.nil? || day_config == :closed
      
      start_time = Time.zone.parse("#{time.to_date} #{day_config[:start]}")
      end_time = Time.zone.parse("#{time.to_date} #{day_config[:end]}")
      
      time.between?(start_time, end_time)
    end
    
    # Formata número de telefone brasileiro
    def format_brazilian_phone(number)
      return number unless number
      
      PHONE_CONFIG[:formatting].call(number)
    end
    
    # Valida se o número é brasileiro válido
    def valid_brazilian_phone?(number)
      return false unless number
      
      PHONE_CONFIG[:number_validation].match?(number)
    end
    
    # Retorna saudação adequada baseada no horário
    def greeting_for_time(time = Time.current)
      time = time.in_time_zone(TIMEZONE)
      hour = time.hour
      
      case hour
      when 5..11
        'Bom dia! ☀️'
      when 12..17
        'Boa tarde! ⛅'
      when 18..23, 0..4
        'Boa noite! 🌙'
      else
        'Olá! 👋'
      end
    end
  end
end

# Alias para compatibilidade com código existente
BrazilCustomizations = Module.new
BrazilCustomizations::Config = Config 