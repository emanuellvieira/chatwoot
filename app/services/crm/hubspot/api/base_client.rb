class Crm::Hubspot::Api::BaseClient
  include HTTParty
  base_uri 'https://api.hubapi.com'
  
  def initialize(access_token, portal_id)
    @access_token = access_token
    @portal_id = portal_id
    @headers = {
      'Authorization' => "Bearer #{@access_token}",
      'Content-Type' => 'application/json'
    }
  end
  
  private
  
  def handle_response(response)
    case response.code
    when 200..299
      response.parsed_response
    when 401
      raise ApiError, 'Unauthorized - check your access token'
    when 429
      raise ApiError, 'Rate limit exceeded'
    else
      raise ApiError, "API Error: #{response.code} - #{response.body}"
    end
  end
  
  class ApiError < StandardError; end
end 