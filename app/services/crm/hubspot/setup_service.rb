class Crm::Hubspot::SetupService
  def initialize(account)
    @account = account
  end
  
  def setup_integration(settings)
    # Validate required settings
    validate_settings(settings)
    
    # Test connection
    test_connection(settings)
    
    # Create or update integration hook
    integration = @account.integration_hooks.find_or_initialize_by(app_id: 'hubspot')
    integration.settings = settings
    integration.save!
    
    integration
  rescue => e
    Rails.logger.error "Error setting up HubSpot integration: #{e.message}"
    raise e
  end
  
  def test_connection(settings)
    client = Crm::Hubspot::Api::ContactClient.new(
      settings['access_token'],
      settings['portal_id']
    )
    
    # Test by getting contact properties
    client.get_contact_properties
  rescue => e
    raise "Failed to connect to HubSpot: #{e.message}"
  end
  
  def get_pipelines(settings)
    client = Crm::Hubspot::Api::DealClient.new(
      settings['access_token'],
      settings['portal_id']
    )
    
    client.get_pipelines
  rescue => e
    Rails.logger.error "Error getting HubSpot pipelines: #{e.message}"
    []
  end
  
  private
  
  def validate_settings(settings)
    required_fields = ['access_token', 'portal_id']
    
    required_fields.each do |field|
      if settings[field].blank?
        raise "Missing required field: #{field}"
      end
    end
  end
end 