class Crm::Hubspot::Api::ContactClient < Crm::Hubspot::Api::BaseClient
  def create_or_update_contact(contact_data)
    response = self.class.post(
      "/crm/v3/objects/contacts/upsert",
      headers: @headers,
      body: { properties: contact_data }.to_json
    )
    result = handle_response(response)
    result['id']
  end
  
  def update_contact(contact_data, contact_id)
    response = self.class.patch(
      "/crm/v3/objects/contacts/#{contact_id}",
      headers: @headers,
      body: { properties: contact_data }.to_json
    )
    handle_response(response)
  end
  
  def find_contact_by_email(email)
    response = self.class.get(
      "/crm/v3/objects/contacts/#{email}?idProperty=email",
      headers: @headers
    )
    handle_response(response)
  rescue ApiError => e
    return nil if e.message.include?('404')
    raise e
  end

  def find_contact_by_whatsapp(whatsapp_number, property_name = 'whatsapp_api')
    response = self.class.post(
      "/crm/v3/objects/contacts/search",
      headers: @headers,
      body: {
        filterGroups: [
          {
            filters: [
              {
                propertyName: property_name,
                operator: 'EQ',
                value: whatsapp_number
              }
            ]
          }
        ],
        properties: ['email', 'firstname', 'lastname', 'phone', property_name]
      }.to_json
    )
    result = handle_response(response)
    result['results']&.first
  rescue ApiError => e
    Rails.logger.error "Error searching contact by WhatsApp: #{e.message}"
    nil
  end
  
  def get_contact_properties
    response = self.class.get(
      "/crm/v3/properties/contacts",
      headers: @headers
    )
    handle_response(response)
  end
  
  def get_contact_by_id(contact_id)
    response = self.class.get(
      "/crm/v3/objects/contacts/#{contact_id}",
      headers: @headers,
      query: { properties: ['email', 'firstname', 'lastname', 'phone', 'whatsapp_api'] }
    )
    handle_response(response)
  rescue ApiError => e
    return nil if e.message.include?('404')
    raise e
  end
end 