# Integração HubSpot para Chatwoot

## 📋 Visão Geral

Esta integração permite sincronização bidirecional entre o Chatwoot e o HubSpot, incluindo:

- **Sincronização de Contatos**: Criação e atualização automática de contatos
- **Atividades de Conversa**: Criação de notas no HubSpot para conversas
- **Deals**: Criação automática de deals para conversas qualificadas
- **Busca por WhatsApp**: Integração com propriedade personalizada `whatsapp_api`
- **Links Diretos**: Acesso rápido ao perfil do contato no HubSpot

## 🚀 Funcionalidades

### 1. Sincronização de Contatos
- **Chatwoot → HubSpot**: Contatos criados/atualizados no Chatwoot são sincronizados automaticamente
- **HubSpot → Chatwoot**: Contatos criados no HubSpot podem ser importados via webhooks
- **Busca Inteligente**: Busca por email ou número WhatsApp (propriedade `whatsapp_api`)

### 2. Atividades de Conversa
- **Nova Conversa**: Cria nota no HubSpot quando conversa é iniciada
- **Transcript**: Cria nota com transcript completo quando conversa é resolvida
- **Informações Detalhadas**: Inclui agente, inbox, status e histórico completo

### 3. Criação de Deals
- **Deals Automáticos**: Cria deals para conversas qualificadas
- **Configurável**: Pipeline e estágio configuráveis
- **Associação**: Vincula deals aos contatos automaticamente

### 4. Interface do Usuário
- **Link Direto**: Botão "Ver no HubSpot" nos perfis de contato
- **Informações Sincronizadas**: Exibe dados do HubSpot no Chatwoot
- **Status de Sincronização**: Indica se contato está sincronizado

## ⚙️ Configuração

### 1. Configuração no HubSpot
1. Acesse o HubSpot Developer Portal
2. Crie um app privado
3. Configure as permissões necessárias:
   - `contacts.read`
   - `contacts.write`
   - `deals.read`
   - `deals.write`
4. Obtenha o Access Token e Portal ID

### 2. Configuração no Chatwoot
1. Acesse **Configurações > Integrações**
2. Selecione **HubSpot**
3. Configure os campos:
   - **Access Token**: Token de acesso do HubSpot
   - **Portal ID**: ID do portal HubSpot
   - **Propriedade WhatsApp**: Nome da propriedade personalizada (padrão: `whatsapp_api`)

### 3. Configurações Opcionais
- **Sincronização de Contatos**: Ativa sincronização automática
- **Atividades de Conversa**: Cria notas para novas conversas
- **Transcript**: Cria notas com transcript completo
- **Deals**: Cria deals automaticamente
- **Pipeline e Estágio**: Configura pipeline e estágio para deals

## 🔧 API Endpoints

### Configuração
- `POST /api/v1/accounts/:account_id/integrations/hubspot` - Configurar integração
- `PUT /api/v1/accounts/:account_id/integrations/hubspot` - Atualizar configuração
- `DELETE /api/v1/accounts/:account_id/integrations/hubspot` - Remover integração
- `POST /api/v1/accounts/:account_id/integrations/hubspot/test_connection` - Testar conexão
- `GET /api/v1/accounts/:account_id/integrations/hubspot/get_pipelines` - Listar pipelines

### Contatos
- `POST /api/v1/accounts/:account_id/contacts/:id/sync_to_hubspot` - Sincronizar contato
- `GET /api/v1/accounts/:account_id/contacts/:id/find_in_hubspot` - Buscar no HubSpot

## 📊 Estrutura de Dados

### Mapeamento de Contatos
```ruby
# Chatwoot → HubSpot
{
  email: contact.email,
  firstname: contact.name.split(' ').first,
  lastname: contact.name.split(' ').drop(1).join(' '),
  phone: contact.phone_number,
  company: contact.additional_attributes['company'],
  jobtitle: contact.additional_attributes['job_title'],
  whatsapp_api: contact.phone_number # Se for número brasileiro
}

# HubSpot → Chatwoot
{
  email: properties['email'],
  name: "#{properties['firstname']} #{properties['lastname']}",
  phone_number: properties['phone'] || properties['whatsapp_api'],
  additional_attributes: {
    company: properties['company'],
    job_title: properties['jobtitle'],
    hubspot_id: contact_id,
    hubspot_url: "https://app.hubspot.com/contacts/#{contact_id}"
  }
}
```

### Atividades de Conversa
```ruby
# Nova Conversa
"Nova conversa iniciada no #{inbox.name}
Assunto: #{conversation.subject}
Inbox: #{inbox.name}
Data: #{conversation.created_at}"

# Transcript
"Conversa finalizada no #{inbox.name}
Agente: #{agent.name}
Status: #{conversation.status}
Transcript completo..."
```

## 🔄 Webhooks

### Eventos Suportados
- `contact.propertyChange` - Mudanças em propriedades de contato
- `contact.creation` - Criação de novo contato
- `deal.propertyChange` - Mudanças em deals
- `deal.creation` - Criação de novo deal

### Configuração de Webhooks
1. Configure webhook no HubSpot Developer Portal
2. URL: `https://seu-chatwoot.com/api/v1/integrations/webhooks`
3. Selecione os eventos desejados

## 🛠️ Desenvolvimento

### Estrutura de Arquivos
```
app/services/crm/hubspot/
├── api/
│   ├── base_client.rb
│   ├── contact_client.rb
│   ├── activity_client.rb
│   └── deal_client.rb
├── mappers/
│   ├── contact_mapper.rb
│   └── conversation_mapper.rb
├── contact_finder_service.rb
├── processor_service.rb
└── setup_service.rb

app/controllers/integrations/
└── hubspot_controller.rb

app/services/integrations/hubspot/
└── webhook_service.rb

app/jobs/crm/
└── hubspot_sync_job.rb

app/helpers/
└── hubspot_helper.rb

app/javascript/dashboard/components/widgets/
├── HubspotLink.vue
└── ContactDetails.vue
```

### Jobs Assíncronos
- `Crm::HubspotSyncJob` - Sincronização assíncrona
- Suporta: sync_contact, conversation_created, conversation_resolved, bulk_sync_contacts

### Tratamento de Erros
- Logs detalhados para debugging
- Retry automático para falhas temporárias
- Fallback graceful para falhas de API

## 🧪 Testes

### Executar Testes
```bash
# Testes unitários
bundle exec rspec spec/services/crm/hubspot/
bundle exec rspec spec/controllers/integrations/

# Testes de integração
bundle exec rspec spec/integration/hubspot/
```

### Cenários de Teste
- Sincronização de contatos
- Criação de atividades
- Tratamento de erros de API
- Webhooks
- Interface do usuário

## 📝 Logs e Monitoramento

### Logs Importantes
```ruby
# Sincronização de contatos
Rails.logger.info "Syncing contact #{contact.id} to HubSpot"

# Erros de API
Rails.logger.error "HubSpot API Error: #{e.message}"

# Webhooks
Rails.logger.info "Processing HubSpot webhook: #{payload['subscriptionType']}"
```

### Métricas
- Contatos sincronizados
- Atividades criadas
- Deals criados
- Taxa de erro
- Tempo de resposta da API

## 🔒 Segurança

### Autenticação
- OAuth 2.0 com HubSpot
- Tokens de acesso seguros
- Refresh tokens automáticos

### Dados Sensíveis
- Tokens criptografados no banco
- Logs sem informações sensíveis
- Validação de entrada

## 🚀 Deploy

### Pré-requisitos
- Ruby 3.4+
- Rails 7.1+
- Redis para jobs assíncronos
- HTTParty gem

### Variáveis de Ambiente
```bash
# Opcional: Configurações globais do HubSpot
HUBSPOT_CLIENT_ID=your_client_id
HUBSPOT_CLIENT_SECRET=your_client_secret
```

### Migração
```bash
# Executar migrações se necessário
bundle exec rails db:migrate

# Verificar configurações
bundle exec rails console
> Account.first.integration_hooks.where(app_id: 'hubspot').count
```

## 📞 Suporte

### Problemas Comuns
1. **Erro de autenticação**: Verificar access token
2. **Rate limiting**: Implementar retry com backoff
3. **Propriedades não encontradas**: Verificar nomes das propriedades no HubSpot

### Debug
```ruby
# Verificar configuração
account = Account.find(1)
integration = account.integration_hooks.find_by(app_id: 'hubspot')
puts integration.settings

# Testar conexão
processor = Crm::Hubspot::ProcessorService.new(account)
processor.sync_contact(contact)
```

## 📈 Roadmap

### Próximas Funcionalidades
- [ ] Sincronização de empresas
- [ ] Automações baseadas em atividades
- [ ] Relatórios de integração
- [ ] Sincronização bidirecional de deals
- [ ] Interface de configuração avançada

### Melhorias
- [ ] Cache de propriedades do HubSpot
- [ ] Sincronização incremental
- [ ] Dashboard de status da integração
- [ ] Notificações de falhas 