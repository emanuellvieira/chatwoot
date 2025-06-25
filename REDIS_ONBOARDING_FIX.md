# Fix para Problema de Onboarding com Redis

## Problema Identificado

O erro que você estava enfrentando tinha duas causas principais:

### 1. Aviso de Depreciação do Redis-Namespace
```
Passing 'call' command to redis as is; blind passthrough has been deprecated and will be removed in redis-namespace 2.0
```

Este aviso ocorre porque o Rails 7.1 está usando `ActiveSupport::Cache::RedisCacheStore` que tenta usar comandos Redis que não são suportados pelo `redis-namespace` da forma como estava configurado.

### 2. Lógica Invertida no DashboardController
O `ensure_installation_onboarding` no `DashboardController` tinha a lógica invertida, causando redirecionamentos incorretos.

## Soluções Implementadas

### 1. Configuração do Cache Store do Rails 7.1
**Arquivo:** `config/initializers/01_redis.rb`

Adicionamos uma configuração específica para o cache do Rails 7.1 que evita conflitos com o `redis-namespace`:

```ruby
# Configure Rails cache store to avoid redis-namespace blind passthrough issues
# This is needed for Rails 7.1+ compatibility with redis-namespace
if Rails.env.production?
  # Use a separate Redis connection for Rails cache to avoid namespace conflicts
  cache_redis = Redis.new(Redis::Config.app)
  Rails.application.config.cache_store = :redis_cache_store, {
    redis: cache_redis,
    pool: false, # Disable Rails internal pooling since we're using a direct connection
    expires_in: 1.day,
    namespace: 'chatwoot_cache'
  }
end
```

### 2. Correção da Lógica do Onboarding
**Arquivo:** `app/controllers/dashboard_controller.rb`

Corrigimos a lógica do `ensure_installation_onboarding`:

```ruby
# ANTES (incorreto):
redirect_to '/installation/onboarding' if ::Redis::Alfred.get(::Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING)

# DEPOIS (correto):
redirect_to '/installation/onboarding' unless ::Redis::Alfred.get(::Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING)
```

### 3. Tasks de Manutenção do Redis
**Arquivo:** `lib/tasks/redis_fix.rake`

Criamos tasks para verificar e corrigir problemas do Redis:

- `rake redis:check` - Verifica a conexão do Redis
- `rake redis:fix_onboarding` - Corrige problemas de onboarding
- `rake redis:reset_onboarding` - Reseta o estado do onboarding

## Como Aplicar as Correções

### 1. Reinicie a Aplicação
Após aplicar as mudanças, reinicie a aplicação:

```bash
# Se estiver usando Docker
docker-compose restart

# Se estiver usando sistema local
sudo systemctl restart chatwoot
```

### 2. Execute as Tasks de Verificação
```bash
# Verificar conexão do Redis
bundle exec rake redis:check

# Corrigir problemas de onboarding
bundle exec rake redis:fix_onboarding
```

### 3. Verifique o Onboarding
Após aplicar as correções, tente acessar o onboarding novamente. O processo deve funcionar corretamente agora.

## Explicação Técnica

### Por que o problema ocorreu?

1. **Rails 7.1 + Redis-Namespace**: O Rails 7.1 introduziu mudanças na forma como o cache é gerenciado, e o `redis-namespace` não estava totalmente compatível com essas mudanças.

2. **Lógica Invertida**: O `DashboardController` estava redirecionando para o onboarding quando a chave estava presente, quando deveria redirecionar quando a chave estava ausente.

3. **Cache Conflicts**: O cache do Rails estava tentando usar comandos Redis que não eram suportados pelo namespace configurado.

### Como a solução funciona?

1. **Cache Separado**: Criamos uma conexão Redis separada para o cache do Rails, evitando conflitos com o namespace usado pelo Chatwoot.

2. **Lógica Correta**: Corrigimos a condição para redirecionar apenas quando o onboarding não foi completado.

3. **Tasks de Manutenção**: As tasks permitem verificar e corrigir problemas do Redis quando necessário.

## Monitoramento

Para monitorar se o problema foi resolvido, verifique:

1. **Logs da Aplicação**: Não deve mais aparecer o aviso sobre "blind passthrough"
2. **Onboarding**: Deve funcionar corretamente sem redirecionamentos em loop
3. **Cache**: O cache do Rails deve funcionar sem erros

## Próximos Passos

1. Teste o onboarding completo
2. Monitore os logs por alguns dias
3. Se necessário, execute `rake redis:check` para verificar a saúde do Redis
4. Considere atualizar o `redis-namespace` para uma versão mais recente quando disponível 