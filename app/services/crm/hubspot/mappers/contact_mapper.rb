class Crm::Hubspot::Mappers::ContactMapper
  def self.map(contact, whatsapp_property_name = 'whatsapp_api')
    contact_data = {
      email: contact.email,
      firstname: contact.name&.split(' ')&.first,
      lastname: contact.name&.split(' ')&.drop(1)&.join(' '),
      phone: contact.phone_number,
      company: contact.additional_attributes&.dig('company'),
      jobtitle: contact.additional_attributes&.dig('job_title'),
      address: contact.additional_attributes&.dig('address'),
      city: contact.additional_attributes&.dig('city'),
      state: contact.additional_attributes&.dig('state'),
      zip: contact.additional_attributes&.dig('zip'),
      country: contact.additional_attributes&.dig('country')
    }
    
    # Add WhatsApp property if phone number exists and is a WhatsApp number
    if contact.phone_number.present? && contact.phone_number.start_with?('55')
      contact_data[whatsapp_property_name] = contact.phone_number
    end
    
    # Remove nil values
    contact_data.compact
  end
  
  def self.map_from_hubspot(hubspot_contact, whatsapp_property_name = 'whatsapp_api')
    properties = hubspot_contact['properties'] || {}
    
    {
      email: properties['email'],
      name: [properties['firstname'], properties['lastname']].compact.join(' '),
      phone_number: properties['phone'] || properties[whatsapp_property_name],
      additional_attributes: {
        company: properties['company'],
        job_title: properties['jobtitle'],
        address: properties['address'],
        city: properties['city'],
        state: properties['state'],
        zip: properties['zip'],
        country: properties['country'],
        hubspot_id: hubspot_contact['id'],
        hubspot_url: "https://app.hubspot.com/contacts/#{hubspot_contact['id']}"
      }
    }
  end
end 