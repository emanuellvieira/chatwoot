class Crm::Hubspot::ProcessorService
  def initialize(account)
    @account = account
    @integration = account.integration_hooks.find_by(app_id: 'hubspot')
    return unless @integration
    
    settings = @integration.settings
    @contact_client = Crm::Hubspot::Api::ContactClient.new(
      settings['access_token'],
      settings['portal_id']
    )
    @activity_client = Crm::Hubspot::Api::ActivityClient.new(
      settings['access_token'],
      settings['portal_id']
    )
    @deal_client = Crm::Hubspot::Api::DealClient.new(
      settings['access_token'],
      settings['portal_id']
    )
    @whatsapp_property = settings['whatsapp_property_name'] || 'whatsapp_api'
  end
  
  def process_conversation_created(conversation)
    return unless @integration&.settings&.dig('enable_conversation_activity')
    
    contact = conversation.contact
    hubspot_id = get_or_create_hubspot_contact(contact)
    return unless hubspot_id
    
    # Create activity
    activity_content = Crm::Hubspot::Mappers::ConversationMapper.map_conversation_activity(conversation)
    @activity_client.create_note(hubspot_id, activity_content)
    
    # Create deal if enabled
    if @integration.settings['enable_deal_creation']
      create_deal_for_conversation(conversation, hubspot_id)
    end
  rescue => e
    Rails.logger.error "Error processing conversation created: #{e.message}"
  end
  
  def process_conversation_resolved(conversation)
    return unless @integration&.settings&.dig('enable_transcript_activity')
    
    contact = conversation.contact
    hubspot_id = get_or_create_hubspot_contact(contact)
    return unless hubspot_id
    
    # Create transcript activity
    transcript_content = Crm::Hubspot::Mappers::ConversationMapper.map_transcript_activity(conversation)
    @activity_client.create_note(hubspot_id, transcript_content)
  rescue => e
    Rails.logger.error "Error processing conversation resolved: #{e.message}"
  end
  
  def sync_contact(contact)
    return unless @integration&.settings&.dig('enable_contact_sync')
    
    contact_data = Crm::Hubspot::Mappers::ContactMapper.map(contact, @whatsapp_property)
    hubspot_id = @contact_client.create_or_update_contact(contact_data)
    
    # Update contact with HubSpot information
    contact.update(
      additional_attributes: contact.additional_attributes.merge(
        hubspot_id: hubspot_id,
        hubspot_url: "https://app.hubspot.com/contacts/#{hubspot_id}"
      )
    )
    
    hubspot_id
  rescue => e
    Rails.logger.error "Error syncing contact: #{e.message}"
    nil
  end
  
  private
  
  def get_or_create_hubspot_contact(contact)
    # Check if contact already has HubSpot ID
    hubspot_id = contact.additional_attributes&.dig('hubspot_id')
    return hubspot_id if hubspot_id
    
    # Try to find existing contact
    if contact.email.present?
      hubspot_contact = @contact_client.find_contact_by_email(contact.email)
      if hubspot_contact
        hubspot_id = hubspot_contact['id']
        update_contact_with_hubspot_info(contact, hubspot_id)
        return hubspot_id
      end
    end
    
    # Try to find by WhatsApp
    if contact.phone_number.present? && contact.phone_number.start_with?('55')
      hubspot_contact = @contact_client.find_contact_by_whatsapp(contact.phone_number, @whatsapp_property)
      if hubspot_contact
        hubspot_id = hubspot_contact['id']
        update_contact_with_hubspot_info(contact, hubspot_id)
        return hubspot_id
      end
    end
    
    # Create new contact
    sync_contact(contact)
  end
  
  def update_contact_with_hubspot_info(contact, hubspot_id)
    contact.update(
      additional_attributes: contact.additional_attributes.merge(
        hubspot_id: hubspot_id,
        hubspot_url: "https://app.hubspot.com/contacts/#{hubspot_id}"
      )
    )
  end
  
  def create_deal_for_conversation(conversation, hubspot_id)
    deal_data = Crm::Hubspot::Mappers::ConversationMapper.map_deal_data(
      conversation,
      @integration.settings['deal_pipeline_id'],
      @integration.settings['deal_stage_id']
    )
    
    @deal_client.create_deal(deal_data, hubspot_id)
  rescue => e
    Rails.logger.error "Error creating deal: #{e.message}"
  end
end 