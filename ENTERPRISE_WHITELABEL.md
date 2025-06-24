# Enterprise Chatwoot Whitelabel

## 🚀 Visão Geral

Esta é uma versão **Enterprise Whitelabel** do Chatwoot, completamente independente do projeto original. Todas as funcionalidades enterprise estão habilitadas por padrão, sem dependências externas ou verificações de licença.

## ✨ Features Habilitadas

### Enterprise Features
- ✅ **Audit Logs** - Logs detalhados de todas as ações
- ✅ **SLA Management** - Gestão de Service Level Agreements
- ✅ **Custom Roles** - Criação de roles personalizados
- ✅ **Captain Integration** - Integração com Captain
- ✅ **Help Center** - Centro de ajuda completo
- ✅ **Automations** - Automações avançadas
- ✅ **CRM Integration** - Integração com CRM
- ✅ **Advanced Reports** - Relatórios avançados
- ✅ **Campaigns** - Campanhas de marketing
- ✅ **Custom Reply Domain** - Domínio personalizado para respostas
- ✅ **Branding Disabled** - Sem branding do Chatwoot

### Premium Features
- ✅ **All Premium Features Enabled**
- ✅ **No License Checks**
- ✅ **Independent Installation**

## 🔧 Configuração

### Variáveis de Ambiente

```bash
# Força modo enterprise
CHATWOOT_ENTERPRISE=true

# Remove branding
DISABLE_BRANDING=true

# Configurações padrão do Chatwoot
FRONTEND_URL=https://your-domain.com
SECRET_KEY_BASE=your-secret-key
REDIS_URL=redis://localhost:6379
POSTGRES_HOST=localhost
POSTGRES_USERNAME=chatwoot
POSTGRES_PASSWORD=password
POSTGRES_DATABASE=chatwoot_production
```

### Configuração do Whitelabel

Edite o arquivo `config/whitelabel.yml` para personalizar:

```yaml
whitelabel:
  company:
    name: "Your Company Name"
    website: "https://your-company.com"
    support_email: "support@your-company.com"
  
  app:
    name: "Your App Name"
    version: "2.0.0-enterprise-whitelabel"
```

## 🚀 Deploy

### Docker (Recomendado)

```bash
# Build da imagem
docker build -t enterprise-chatwoot .

# Executar
docker run -d \
  -p 3000:3000 \
  -e FRONTEND_URL=https://your-domain.com \
  -e SECRET_KEY_BASE=your-secret-key \
  -e REDIS_URL=redis://redis:6379 \
  -e POSTGRES_HOST=postgres \
  -e POSTGRES_USERNAME=chatwoot \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DATABASE=chatwoot_production \
  enterprise-chatwoot
```

### Easypanel

1. **Owner**: `emanuellvieira`
2. **Repo**: `chatwoot`
3. **Branch**: `fork-customizations`
4. **Build Path**: `/`
5. **Dockerfile Path**: `Dockerfile`

### Variáveis de Ambiente para Easypanel

```bash
FRONTEND_URL=https://your-domain.com
SECRET_KEY_BASE=your-secret-key
REDIS_URL=redis://redis:6379
POSTGRES_HOST=postgres
POSTGRES_USERNAME=chatwoot
POSTGRES_PASSWORD=password
POSTGRES_DATABASE=chatwoot_production
CHATWOOT_ENTERPRISE=true
DISABLE_BRANDING=true
```

## 🔒 Segurança

### Isolamento
- ✅ **Independent Installation** - Sem dependências do Chatwoot original
- ✅ **No External Checks** - Não faz verificações externas
- ✅ **Custom Authentication** - Autenticação personalizada
- ✅ **Enterprise Licensing Disabled** - Sem verificação de licença

### Configurações de Segurança
- Todas as verificações de licença foram removidas
- O app funciona completamente offline
- Não há comunicação com servidores externos do Chatwoot
- Suporte ao Chatwoot foi desabilitado

## 📊 Monitoramento

### Logs
- Logs detalhados de todas as ações (Audit Logs)
- Logs de sistema para debugging
- Logs de performance

### Métricas
- Relatórios avançados habilitados
- Métricas de conversas
- Métricas de agentes
- Métricas de campanhas

## 🛠️ Desenvolvimento

### Estrutura do Projeto
```
├── config/
│   ├── enterprise_whitelabel.rb    # Configuração enterprise
│   ├── whitelabel_config.rb        # Carregador de configurações
│   └── whitelabel.yml              # Configurações do whitelabel
├── lib/
│   └── chatwoot_app.rb             # App modificado para enterprise
└── ENTERPRISE_WHITELABEL.md        # Esta documentação
```

### Modificações Principais
1. **ChatwootApp** - Sempre retorna enterprise
2. **Features** - Todas habilitadas por padrão
3. **Branding** - Removido branding do Chatwoot
4. **Licensing** - Verificações de licença removidas

## 🔄 Atualizações

### Como Atualizar
1. Faça merge das atualizações do Chatwoot original
2. Mantenha as modificações do whitelabel
3. Teste todas as funcionalidades enterprise
4. Deploy da nova versão

### Compatibilidade
- Compatível com atualizações do Chatwoot
- Modificações mínimas para manter enterprise
- Estrutura modular para fácil manutenção

## 📞 Suporte

### Documentação
- [Chatwoot Enterprise Docs](https://www.chatwoot.com/docs/enterprise)
- [API Documentation](https://www.chatwoot.com/developers/api)

### Configuração
- Edite `config/whitelabel.yml` para personalizar
- Configure variáveis de ambiente
- Ajuste branding conforme necessário

## 🎯 Próximos Passos

1. **Personalização de Branding**
   - Logo personalizado
   - Cores da empresa
   - Textos customizados

2. **Integrações Específicas**
   - APIs customizadas
   - Webhooks personalizados
   - Integrações com sistemas internos

3. **Funcionalidades Adicionais**
   - Módulos customizados
   - Relatórios específicos
   - Automações avançadas

---

**Enterprise Chatwoot Whitelabel** - Versão 2.0.0
*Completamente independente e com todas as funcionalidades enterprise habilitadas* 