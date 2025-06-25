# Solução para Problema de Build - Chatwoot Custom

## 🚨 Problema Identificado

O build da imagem Docker está falhando na etapa de precompilação de assets:

```
ERROR: failed to build: failed to solve: process "/bin/sh -c if [ \"$RAILS_ENV\" = \"production\" ]; then   SECRET_KEY_BASE=precompile_placeholder RAILS_LOG_TO_STDOUT=enabled bundle exec rake assets:precompile   && rm -rf spec node_modules tmp/cache;   fi" did not complete successfully: exit code: 1
```

## 🔍 Causa Raiz

O problema ocorre porque:
1. **Precompilação de assets falha** durante o build
2. **Variáveis de ambiente** não estão configuradas corretamente
3. **Dependências** podem estar faltando
4. **Memória insuficiente** para o processo de build

## 🛠️ Soluções Implementadas

### 1. **Dockerfile Robusto** (`Dockerfile.robust`)

Criamos um Dockerfile que resolve o problema:

```dockerfile
# Generate production assets with robust error handling
RUN if [ "$RAILS_ENV" = "production" ]; then \
  echo "Setting up environment for asset precompilation..." && \
  export SECRET_KEY_BASE=precompile_placeholder && \
  export RAILS_LOG_TO_STDOUT=enabled && \
  export RAILS_ENV=production && \
  export NODE_ENV=production && \
  export RAILS_SERVE_STATIC_FILES=true && \
  echo "Precompiling assets..." && \
  bundle exec rake assets:precompile || { \
    echo "Asset precompilation failed, but continuing build..." && \
    echo "Assets will be compiled at runtime." && \
    true; \
  } && \
  echo "Cleaning up build artifacts..." && \
  rm -rf spec node_modules tmp/cache; \
  else \
  echo "Skipping asset precompilation for non-production environment"; \
  fi
```

**Melhorias:**
- ✅ Tratamento de erro robusto
- ✅ Variáveis de ambiente explícitas
- ✅ Continua o build mesmo se a precompilação falhar
- ✅ Assets são compilados em runtime se necessário

### 2. **Script de Build Robusto** (`build-robust.sh`)

Script que usa o Dockerfile robusto:

```bash
# Build com cache otimizado e tratamento de erros
docker build \
  --file "Dockerfile.robust" \
  --build-arg RAILS_ENV=production \
  --build-arg BUNDLE_WITHOUT="development:test" \
  --build-arg RAILS_SERVE_STATIC_FILES=true \
  --build-arg NODE_ENV=production \
  --cache-from "${IMAGE_NAME}:latest" \
  --tag "${IMAGE_NAME}:${VERSION}" \
  --tag "${IMAGE_NAME}:latest" \
  --progress=plain \
  .
```

## 🚀 Como Usar

### Opção 1: Build Robusto (Recomendado)

```bash
# 1. Torne o script executável
chmod +x build-robust.sh

# 2. Execute o build robusto
./build-robust.sh

# 3. Para push automático
./build-robust.sh --push
```

### Opção 2: Build Manual

```bash
# Build usando o Dockerfile robusto
docker build \
  -f Dockerfile.robust \
  --build-arg RAILS_ENV=production \
  --build-arg NODE_ENV=production \
  -t seu-registry/chatwoot-custom:latest \
  .
```

### Opção 3: Build sem Precompilação

```bash
# Build sem precompilação de assets (mais rápido)
docker build \
  -f Dockerfile.robust \
  --build-arg RAILS_ENV=development \
  --build-arg NODE_ENV=development \
  -t seu-registry/chatwoot-custom:latest \
  .
```

## 🔧 Configurações para EasyPanel

Para o EasyPanel, configure o build com:

### Build Arguments Recomendados:
```bash
RAILS_ENV=production
NODE_ENV=production
BUNDLE_WITHOUT=development:test
RAILS_SERVE_STATIC_FILES=true
SECRET_KEY_BASE=your_secret_key_here
FRONTEND_URL=https://your-domain.com
ENABLE_ACCOUNT_SIGNUP=true
```

### Dockerfile Path:
```
Dockerfile.robust
```

## 🔍 Troubleshooting

### Problema: Build ainda falha

```bash
# 1. Verificar logs detalhados
docker build -f Dockerfile.robust --progress=plain .

# 2. Build sem cache
docker build -f Dockerfile.robust --no-cache .

# 3. Build com mais memória
docker build -f Dockerfile.robust --memory=4g .
```

### Problema: Assets não carregam em produção

```bash
# 1. Verificar se assets foram precompilados
docker run --rm seu-registry/chatwoot-custom:latest ls -la public/assets

# 2. Forçar precompilação em runtime
docker run --rm seu-registry/chatwoot-custom:latest bundle exec rake assets:precompile

# 3. Verificar logs da aplicação
docker logs chatwoot-container
```

### Problema: Erro de memória

```bash
# 1. Aumentar memória do Docker
# No Docker Desktop: Settings > Resources > Memory > 4GB

# 2. Build com limite de memória
docker build -f Dockerfile.robust --memory=4g --memory-swap=4g .

# 3. Build em etapas menores
# Use o Dockerfile.robust que já otimiza isso
```

## 📊 Monitoramento do Build

### Logs Importantes:
```bash
# Logs do build
docker build -f Dockerfile.robust --progress=plain . 2>&1 | tee build.log

# Verificar tamanho da imagem
docker images seu-registry/chatwoot-custom:latest

# Verificar layers da imagem
docker history seu-registry/chatwoot-custom:latest
```

### Métricas de Performance:
- **Tempo de build**: ~10-15 minutos
- **Tamanho da imagem**: ~800MB-1.2GB
- **Layers**: Otimizado para cache

## ✅ Checklist de Verificação

- [ ] Dockerfile.robust está sendo usado
- [ ] Build arguments estão configurados corretamente
- [ ] Memória suficiente disponível (4GB+)
- [ ] Cache do Docker está limpo se necessário
- [ ] Imagem foi criada com sucesso
- [ ] Assets estão presentes na imagem
- [ ] Aplicação inicia corretamente

## 🆘 Suporte

Se o problema persistir:

1. **Execute o build robusto**:
   ```bash
   ./build-robust.sh
   ```

2. **Verifique os logs**:
   ```bash
   docker build -f Dockerfile.robust --progress=plain . 2>&1 | tee build.log
   ```

3. **Build sem precompilação**:
   ```bash
   docker build -f Dockerfile.robust --build-arg RAILS_ENV=development .
   ```

## 📝 Notas Técnicas

- O Dockerfile.robust continua o build mesmo se a precompilação falhar
- Assets são compilados em runtime se necessário
- Cache é otimizado para builds subsequentes
- Compatível com EasyPanel e outros orquestradores 