class Crm::Hubspot::Api::DealClient < Crm::Hubspot::Api::BaseClient
  def create_deal(deal_data, contact_id = nil)
    deal_payload = {
      properties: deal_data
    }
    
    if contact_id
      deal_payload[:associations] = [
        {
          to: {
            id: contact_id
          },
          types: [
            {
              associationCategory: 'HUBSPOT_DEFINED',
              associationTypeId: 3
            }
          ]
        }
      ]
    end
    
    response = self.class.post(
      "/crm/v3/objects/deals",
      headers: @headers,
      body: deal_payload.to_json
    )
    result = handle_response(response)
    result['id']
  end
  
  def get_pipelines
    response = self.class.get(
      "/crm/v3/pipelines/deals",
      headers: @headers
    )
    handle_response(response)
  end
end 