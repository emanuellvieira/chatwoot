class Crm::Hubspot::Api::ActivityClient < Crm::Hubspot::Api::BaseClient
  def create_note(contact_id, note_content)
    note_data = {
      properties: {
        hs_note_body: note_content,
        hs_timestamp: Time.current.to_i * 1000
      },
      associations: [
        {
          to: {
            id: contact_id
          },
          types: [
            {
              associationCategory: 'HUBSPOT_DEFINED',
              associationTypeId: 1
            }
          ]
        }
      ]
    }
    
    response = self.class.post(
      "/crm/v3/objects/notes",
      headers: @headers,
      body: note_data.to_json
    )
    result = handle_response(response)
    result['id']
  end
end 