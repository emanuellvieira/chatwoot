class Integrations::Hubspot::WebhookService
  def initialize(account)
    @account = account
    @integration = account.integration_hooks.find_by(app_id: 'hubspot')
  end
  
  def process_webhook(payload)
    return unless @integration
    
    case payload['subscriptionType']
    when 'contact.propertyChange'
      process_contact_update(payload)
    when 'contact.creation'
      process_contact_creation(payload)
    when 'deal.propertyChange'
      process_deal_update(payload)
    when 'deal.creation'
      process_deal_creation(payload)
    end
  rescue => e
    Rails.logger.error "Error processing HubSpot webhook: #{e.message}"
  end
  
  private
  
  def process_contact_update(payload)
    contact_id = payload['objectId']
    properties = payload['propertyNameToOldValue'] || {}
    
    # Find contact in Chatwoot by HubSpot ID
    contact = @account.contacts.find_by(
      "additional_attributes->>'hubspot_id' = ?", contact_id.to_s
    )
    
    return unless contact
    
    # Update contact properties
    update_contact_from_hubspot(contact, properties)
  end
  
  def process_contact_creation(payload)
    contact_id = payload['objectId']
    
    # Get contact details from HubSpot
    client = Crm::Hubspot::Api::ContactClient.new(
      @integration.settings['access_token'],
      @integration.settings['portal_id']
    )
    
    hubspot_contact = client.get_contact_by_id(contact_id)
    return unless hubspot_contact
    
    # Create or update contact in Chatwoot
    create_or_update_contact_from_hubspot(hubspot_contact)
  end
  
  def process_deal_update(payload)
    # Handle deal updates if needed
    Rails.logger.info "Deal update webhook received: #{payload['objectId']}"
  end
  
  def process_deal_creation(payload)
    # Handle deal creation if needed
    Rails.logger.info "Deal creation webhook received: #{payload['objectId']}"
  end
  
  def update_contact_from_hubspot(contact, properties)
    # Update contact attributes based on changed properties
    properties.each do |property_name, old_value|
      case property_name
      when 'email'
        contact.update(email: properties['email']) if properties['email']
      when 'firstname', 'lastname'
        firstname = properties['firstname'] || contact.name&.split(' ')&.first
        lastname = properties['lastname'] || contact.name&.split(' ')&.drop(1)&.join(' ')
        contact.update(name: [firstname, lastname].compact.join(' '))
      when 'phone'
        contact.update(phone_number: properties['phone']) if properties['phone']
      when 'company'
        additional_attrs = contact.additional_attributes.merge(company: properties['company'])
        contact.update(additional_attributes: additional_attrs)
      end
    end
  end
  
  def create_or_update_contact_from_hubspot(hubspot_contact)
    contact_data = Crm::Hubspot::Mappers::ContactMapper.map_from_hubspot(
      hubspot_contact,
      @integration.settings['whatsapp_property_name'] || 'whatsapp_api'
    )
    
    # Try to find existing contact by email or phone
    existing_contact = nil
    if contact_data[:email].present?
      existing_contact = @account.contacts.find_by(email: contact_data[:email])
    end
    
    if !existing_contact && contact_data[:phone_number].present?
      existing_contact = @account.contacts.find_by(phone_number: contact_data[:phone_number])
    end
    
    if existing_contact
      # Update existing contact
      existing_contact.update(
        name: contact_data[:name],
        phone_number: contact_data[:phone_number],
        additional_attributes: existing_contact.additional_attributes.merge(
          contact_data[:additional_attributes]
        )
      )
    else
      # Create new contact
      @account.contacts.create!(
        name: contact_data[:name],
        email: contact_data[:email],
        phone_number: contact_data[:phone_number],
        additional_attributes: contact_data[:additional_attributes]
      )
    end
  end
end 