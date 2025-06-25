class Crm::HubspotSyncJob < ApplicationJob
  queue_as :default
  
  def perform(account_id, action, data = {})
    account = Account.find(account_id)
    processor = Crm::Hubspot::ProcessorService.new(account)
    
    case action
    when 'sync_contact'
      contact = Contact.find(data['contact_id'])
      processor.sync_contact(contact)
    when 'conversation_created'
      conversation = Conversation.find(data['conversation_id'])
      processor.process_conversation_created(conversation)
    when 'conversation_resolved'
      conversation = Conversation.find(data['conversation_id'])
      processor.process_conversation_resolved(conversation)
    when 'bulk_sync_contacts'
      sync_all_contacts(account, processor)
    end
  rescue => e
    Rails.logger.error "Error in HubSpot sync job: #{e.message}"
    raise e
  end
  
  private
  
  def sync_all_contacts(account, processor)
    # Sync contacts in batches to avoid memory issues
    account.contacts.find_in_batches(batch_size: 100) do |contacts|
      contacts.each do |contact|
        begin
          processor.sync_contact(contact)
        rescue => e
          Rails.logger.error "Error syncing contact #{contact.id}: #{e.message}"
        end
      end
    end
  end
end 