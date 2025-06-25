class Integrations::HubspotController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account
  before_action :check_admin_authorization
  
  def create
    setup_service = Crm::Hubspot::SetupService.new(@account)
    
    begin
      integration = setup_service.setup_integration(hubspot_params)
      
      render json: {
        success: true,
        message: 'HubSpot integration configured successfully',
        integration: integration
      }
    rescue => e
      render json: {
        success: false,
        message: e.message
      }, status: :unprocessable_entity
    end
  end
  
  def update
    setup_service = Crm::Hubspot::SetupService.new(@account)
    
    begin
      integration = setup_service.setup_integration(hubspot_params)
      
      render json: {
        success: true,
        message: 'HubSpot integration updated successfully',
        integration: integration
      }
    rescue => e
      render json: {
        success: false,
        message: e.message
      }, status: :unprocessable_entity
    end
  end
  
  def destroy
    integration = @account.integration_hooks.find_by(app_id: 'hubspot')
    
    if integration
      integration.destroy
      render json: {
        success: true,
        message: 'HubSpot integration removed successfully'
      }
    else
      render json: {
        success: false,
        message: 'HubSpot integration not found'
      }, status: :not_found
    end
  end
  
  def test_connection
    setup_service = Crm::Hubspot::SetupService.new(@account)
    
    begin
      setup_service.test_connection(hubspot_params)
      render json: {
        success: true,
        message: 'Connection to HubSpot successful'
      }
    rescue => e
      render json: {
        success: false,
        message: e.message
      }, status: :unprocessable_entity
    end
  end
  
  def get_pipelines
    setup_service = Crm::Hubspot::SetupService.new(@account)
    
    begin
      pipelines = setup_service.get_pipelines(hubspot_params)
      render json: {
        success: true,
        pipelines: pipelines
      }
    rescue => e
      render json: {
        success: false,
        message: e.message
      }, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_account
    @account = current_user.account
  end
  
  def check_admin_authorization
    unless current_user.administrator?
      render json: {
        success: false,
        message: 'Only administrators can manage integrations'
      }, status: :forbidden
    end
  end
  
  def hubspot_params
    params.require(:hubspot).permit(
      :access_token,
      :refresh_token,
      :client_id,
      :client_secret,
      :portal_id,
      :enable_contact_sync,
      :enable_conversation_activity,
      :enable_transcript_activity,
      :enable_deal_creation,
      :enable_whatsapp_sync,
      :whatsapp_property_name,
      :deal_pipeline_id,
      :deal_stage_id,
      contact_properties: []
    )
  end
end 