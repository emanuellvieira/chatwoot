module HubspotHelper
  def hubspot_contact_url(contact)
    hubspot_id = contact.additional_attributes&.dig('hubspot_id')
    return nil unless hubspot_id
    
    "https://app.hubspot.com/contacts/#{hubspot_id}"
  end
  
  def hubspot_contact_link(contact, text = nil)
    url = hubspot_contact_url(contact)
    return nil unless url
    
    text ||= "Ver no HubSpot"
    link_to text, url, target: '_blank', class: 'hubspot-link'
  end
  
  def hubspot_integration_enabled?(account)
    account.integration_hooks.exists?(app_id: 'hubspot')
  end
  
  def hubspot_contact_sync_enabled?(account)
    integration = account.integration_hooks.find_by(app_id: 'hubspot')
    integration&.settings&.dig('enable_contact_sync')
  end
end 