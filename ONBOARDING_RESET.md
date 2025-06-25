# Reset Seguro do Onboarding - Chatwoot

## Para resetar o onboarding e garantir o fluxo padrão:

### 1. Remover todos os usuários e resetar onboarding (⚠️ apaga tudo!)
```bash
bundle exec rake onboarding:hard_reset
```
Digite `SIM` para confirmar.

### 2. Apenas resetar a chave de onboarding no Redis (mantém usuários)
```bash
bundle exec rake onboarding:reset_redis
```

## Recomendações
- Nunca rode seeds de desenvolvimento em produção.
- Em produção, o onboarding só aparece se não houver usuários e a chave de onboarding não existir no Redis.
- Use o reset completo **apenas** em ambientes de teste ou para reinstalação do zero. 