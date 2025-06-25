class Crm::Hubspot::ContactFinderService
  def initialize(account)
    @account = account
    @integration = account.integration_hooks.find_by(app_id: 'hubspot')
    return unless @integration
    
    settings = @integration.settings
    @client = Crm::Hubspot::Api::ContactClient.new(
      settings['access_token'],
      settings['portal_id']
    )
    @whatsapp_property = settings['whatsapp_property_name'] || 'whatsapp_api'
  end
  
  def find_contact(contact)
    return nil unless @integration&.settings&.dig('enable_contact_sync')
    
    # Try to find by email first
    if contact.email.present?
      hubspot_contact = @client.find_contact_by_email(contact.email)
      return hubspot_contact if hubspot_contact
    end
    
    # Try to find by WhatsApp number
    if contact.phone_number.present? && contact.phone_number.start_with?('55')
      hubspot_contact = @client.find_contact_by_whatsapp(contact.phone_number, @whatsapp_property)
      return hubspot_contact if hubspot_contact
    end
    
    nil
  end
  
  def sync_contact_to_hubspot(contact)
    return nil unless @integration&.settings&.dig('enable_contact_sync')
    
    contact_data = Crm::Hubspot::Mappers::ContactMapper.map(contact, @whatsapp_property)
    hubspot_id = @client.create_or_update_contact(contact_data)
    
    # Update contact with HubSpot ID
    contact.update(
      additional_attributes: contact.additional_attributes.merge(
        hubspot_id: hubspot_id,
        hubspot_url: "https://app.hubspot.com/contacts/#{hubspot_id}"
      )
    )
    
    hubspot_id
  rescue => e
    Rails.logger.error "Error syncing contact to HubSpot: #{e.message}"
    nil
  end
end 