# Solução para Problema de Onboarding - Chatwoot Custom

## 🚨 Problema Identificado

O onboarding não está aparecendo na nova instalação do Chatwoot. O sistema está indo direto para a tela de login mesmo sem usuários cadastrados.

## 🔍 Causa Raiz

O problema ocorre porque:
1. A chave Redis `CHATWOOT_INSTALLATION_ONBOARDING` não está configurada corretamente
2. O sistema espera que a chave seja `nil` para mostrar o onboarding
3. Pode haver configurações conflitantes no ambiente

## 🛠️ Solução Rápida

### Opção 1: Correção Manual (Mais Rápida)

```bash
# 1. Acesse o container do Chatwoot
docker-compose -f docker-compose.custom.yaml exec chatwoot bash

# 2. Execute o diagnóstico
bundle exec rake onboarding:diagnose

# 3. Habilite o onboarding
bundle exec rake onboarding:enable

# 4. Verifique o status
bundle exec rake onboarding:check

# 5. Saia do container
exit
```

### Opção 2: Script Automatizado

```bash
# 1. Torne o script executável
chmod +x scripts/deploy-with-onboarding-fix.sh

# 2. Execute o deploy com correção automática
./scripts/deploy-with-onboarding-fix.sh
```

### Opção 3: Comandos Individuais

```bash
# Verificar status atual
docker-compose -f docker-compose.custom.yaml exec chatwoot bundle exec rake onboarding:check

# Resetar onboarding (força exibição)
docker-compose -f docker-compose.custom.yaml exec chatwoot bundle exec rake onboarding:reset

# Habilitar onboarding para nova instalação
docker-compose -f docker-compose.custom.yaml exec chatwoot bundle exec rake onboarding:enable

# Diagnóstico completo
docker-compose -f docker-compose.custom.yaml exec chatwoot bundle exec rake onboarding:diagnose
```

## 📋 Verificação do Problema

### 1. Verificar Status do Redis

```bash
# Acesse o container
docker-compose -f docker-compose.custom.yaml exec chatwoot bash

# Verifique a chave de onboarding
bundle exec rails console
> Redis::Alfred.get(Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING)
# Deve retornar nil para mostrar onboarding
```

### 2. Verificar Usuários Existentes

```bash
# No console do Rails
> User.count
# Deve retornar 0 para nova instalação
```

### 3. Verificar Configurações

```bash
# Verificar variáveis de ambiente
echo $RAILS_ENV
echo $INSTALLATION_ENV
echo $ENABLE_ACCOUNT_SIGNUP
```

## 🔧 Configurações Importantes

### Variáveis de Ambiente (.env)

```bash
# Essenciais para onboarding
RAILS_ENV=production
INSTALLATION_ENV=docker_custom
ENABLE_ACCOUNT_SIGNUP=true
SECRET_KEY_BASE=your_secret_key_here
FRONTEND_URL=http://localhost:3000

# Banco de dados
DATABASE_URL=postgresql://postgres:password@postgres:5432/chatwoot
# ou
POSTGRES_HOST=postgres
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=password

# Redis
REDIS_URL=redis://:password@redis:6379/0
```

### Docker Compose

Certifique-se de que o `docker-compose.custom.yaml` inclui:

```yaml
environment:
  - INSTALLATION_ENV=docker_custom
  - ENABLE_ACCOUNT_SIGNUP=true
  - RAILS_LOG_TO_STDOUT=true
```

## 🚀 Deploy Completo

### 1. Preparação

```bash
# Clone o repositório
git clone <seu-repo-chatwoot-custom>
cd chatwoot-custom

# Configure o ambiente
cp .env.example .env
# Edite .env com suas configurações
```

### 2. Build da Imagem

```bash
# Build local
docker build -f Dockerfile.custom -t seu-registry/chatwoot-custom:latest .

# Ou use o script
./build.sh
```

### 3. Deploy com Correção

```bash
# Deploy automático com correção de onboarding
./scripts/deploy-with-onboarding-fix.sh
```

## 🔍 Troubleshooting

### Problema: Onboarding não aparece após correção

```bash
# 1. Verificar logs
docker-compose -f docker-compose.custom.yaml logs chatwoot

# 2. Verificar Redis
docker-compose -f docker-compose.custom.yaml exec chatwoot bundle exec rake onboarding:diagnose

# 3. Forçar reset
docker-compose -f docker-compose.custom.yaml exec chatwoot bundle exec rake onboarding:reset

# 4. Reiniciar aplicação
docker-compose -f docker-compose.custom.yaml restart chatwoot
```

### Problema: Erro de conexão com Redis

```bash
# 1. Verificar se Redis está rodando
docker-compose -f docker-compose.custom.yaml ps redis

# 2. Verificar logs do Redis
docker-compose -f docker-compose.custom.yaml logs redis

# 3. Reiniciar Redis
docker-compose -f docker-compose.custom.yaml restart redis
```

### Problema: Erro de banco de dados

```bash
# 1. Verificar conexão
docker-compose -f docker-compose.custom.yaml exec chatwoot bundle exec rails db:version

# 2. Executar migrações
docker-compose -f docker-compose.custom.yaml exec chatwoot bundle exec rails db:migrate

# 3. Verificar logs
docker-compose -f docker-compose.custom.yaml logs postgres
```

## 📊 Monitoramento

### Logs Importantes

```bash
# Logs da aplicação
docker-compose -f docker-compose.custom.yaml logs -f chatwoot

# Logs do Sidekiq
docker-compose -f docker-compose.custom.yaml logs -f sidekiq

# Logs do Redis
docker-compose -f docker-compose.custom.yaml logs -f redis
```

### Métricas de Saúde

```bash
# Health check da aplicação
curl -f http://localhost:3000/health

# Status dos containers
docker-compose -f docker-compose.custom.yaml ps

# Uso de recursos
docker stats
```

## ✅ Checklist de Verificação

- [ ] Redis está rodando e acessível
- [ ] Chave `CHATWOOT_INSTALLATION_ONBOARDING` é `nil`
- [ ] Não há usuários cadastrados (`User.count == 0`)
- [ ] Variável `ENABLE_ACCOUNT_SIGNUP=true`
- [ ] Variável `INSTALLATION_ENV=docker_custom`
- [ ] Aplicação está respondendo em `http://localhost:3000`
- [ ] Logs não mostram erros críticos

## 🆘 Suporte

Se o problema persistir:

1. **Execute o diagnóstico completo**:
   ```bash
   docker-compose -f docker-compose.custom.yaml exec chatwoot bundle exec rake onboarding:diagnose
   ```

2. **Verifique os logs**:
   ```bash
   docker-compose -f docker-compose.custom.yaml logs --tail=50
   ```

3. **Reset completo**:
   ```bash
   docker-compose -f docker-compose.custom.yaml down
   docker-compose -f docker-compose.custom.yaml up -d
   docker-compose -f docker-compose.custom.yaml exec chatwoot bundle exec rake onboarding:enable
   ```

## 📝 Notas Técnicas

- O onboarding só aparece quando `CHATWOOT_INSTALLATION_ONBOARDING` é `nil` E não há usuários
- Após completar o onboarding, a chave é automaticamente deletada
- Para forçar o onboarding novamente, use `rake onboarding:reset`
- O sistema mantém compatibilidade com instalações existentes 