class Crm::Hubspot::Mappers::ConversationMapper
  def self.map_conversation_activity(conversation)
    contact = conversation.contact
    inbox = conversation.inbox
    
    content = "Nova conversa iniciada no #{inbox.name}\n"
    content += "Assunto: #{conversation.subject || 'Sem assunto'}\n"
    content += "Inbox: #{inbox.name}\n"
    content += "Data: #{conversation.created_at.strftime('%d/%m/%Y %H:%M')}\n"
    
    if conversation.messages.any?
      first_message = conversation.messages.first
      content += "\nPrimeira mensagem:\n#{first_message.content}"
    end
    
    content
  end
  
  def self.map_transcript_activity(conversation)
    contact = conversation.contact
    inbox = conversation.inbox
    agent = conversation.assignee
    
    content = "Conversa finalizada no #{inbox.name}\n"
    content += "Assunto: #{conversation.subject || 'Sem assunto'}\n"
    content += "Inbox: #{inbox.name}\n"
    content += "Agente: #{agent&.name || 'Não atribuído'}\n"
    content += "Status: #{conversation.status}\n"
    content += "Data de início: #{conversation.created_at.strftime('%d/%m/%Y %H:%M')}\n"
    content += "Data de finalização: #{conversation.resolved_at&.strftime('%d/%m/%Y %H:%M') || 'Não finalizada'}\n"
    
    # Add transcript if available
    if conversation.messages.any?
      content += "\n\nTranscript da conversa:\n"
      content += "=" * 50 + "\n"
      
      conversation.messages.order(:created_at).each do |message|
        sender = message.outgoing? ? (agent&.name || 'Sistema') : contact.name
        content += "[#{message.created_at.strftime('%H:%M')}] #{sender}: #{message.content}\n"
      end
    end
    
    content
  end
  
  def self.map_deal_data(conversation, pipeline_id = nil, stage_id = nil)
    contact = conversation.contact
    inbox = conversation.inbox
    
    deal_data = {
      dealname: "Conversa - #{contact.name} - #{inbox.name}",
      amount: "0",
      dealstage: stage_id || "appointmentscheduled",
      pipeline: pipeline_id || "default",
      closedate: (Time.current + 30.days).strftime('%Y-%m-%d'),
      description: "Deal criado automaticamente a partir de conversa no Chatwoot"
    }
    
    deal_data
  end
end 