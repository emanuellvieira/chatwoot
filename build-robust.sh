#!/bin/bash

# Script de Build Robusto para Chatwoot Custom
# Resolve problemas de precompilação de assets

set -e

# Configurações
IMAGE_NAME="seu-registry/chatwoot-custom"
VERSION=$(git rev-parse --short HEAD)
BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
DOCKERFILE="Dockerfile.robust"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🏗️  Build Robusto do Chatwoot Custom${NC}"
echo -e "${BLUE}📦 Imagem: ${IMAGE_NAME}:${VERSION}${NC}"
echo -e "${BLUE}📋 Dockerfile: ${DOCKERFILE}${NC}"

# Verificar se o Dockerfile existe
if [ ! -f "$DOCKERFILE" ]; then
  echo -e "${RED}❌ Dockerfile ${DOCKERFILE} não encontrado!${NC}"
  exit 1
fi

# Verificar se o Docker está rodando
if ! docker info > /dev/null 2>&1; then
  echo -e "${RED}❌ Docker não está rodando!${NC}"
  exit 1
fi

# Build com configurações otimizadas
echo -e "${YELLOW}🔨 Iniciando build robusto...${NC}"

# Build com cache otimizado e tratamento de erros
docker build \
  --file "$DOCKERFILE" \
  --build-arg RAILS_ENV=production \
  --build-arg BUNDLE_WITHOUT="development:test" \
  --build-arg RAILS_SERVE_STATIC_FILES=true \
  --build-arg NODE_ENV=production \
  --build-arg BUILD_DATE="${BUILD_DATE}" \
  --cache-from "${IMAGE_NAME}:latest" \
  --tag "${IMAGE_NAME}:${VERSION}" \
  --tag "${IMAGE_NAME}:latest" \
  --progress=plain \
  . || {
    echo -e "${YELLOW}⚠️  Build falhou, tentando build sem cache...${NC}"
    docker build \
      --file "$DOCKERFILE" \
      --build-arg RAILS_ENV=production \
      --build-arg BUNDLE_WITHOUT="development:test" \
      --build-arg RAILS_SERVE_STATIC_FILES=true \
      --build-arg NODE_ENV=production \
      --build-arg BUILD_DATE="${BUILD_DATE}" \
      --no-cache \
      --tag "${IMAGE_NAME}:${VERSION}" \
      --tag "${IMAGE_NAME}:latest" \
      --progress=plain \
      .
  }

echo -e "${GREEN}✅ Build concluído com sucesso!${NC}"
echo -e "${GREEN}📋 Tags criadas:${NC}"
echo -e "   - ${IMAGE_NAME}:${VERSION}"
echo -e "   - ${IMAGE_NAME}:latest"

# Verificar se a imagem foi criada
if docker images | grep -q "${IMAGE_NAME}.*${VERSION}"; then
  echo -e "${GREEN}✅ Imagem verificada com sucesso!${NC}"
else
  echo -e "${RED}❌ Erro: Imagem não foi criada corretamente${NC}"
  exit 1
fi

# Informações da imagem
echo -e "${BLUE}📊 Informações da imagem:${NC}"
docker images "${IMAGE_NAME}:${VERSION}" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

# Push para registry (opcional)
if [ "$1" = "--push" ]; then
  echo -e "${YELLOW}🚀 Fazendo push para registry...${NC}"
  docker push "${IMAGE_NAME}:${VERSION}"
  docker push "${IMAGE_NAME}:latest"
  echo -e "${GREEN}✅ Push concluído!${NC}"
fi

echo -e "${GREEN}🎉 Build robusto finalizado!${NC}"
echo -e "${BLUE}📝 Próximos passos:${NC}"
echo -e "   1. Use a imagem: ${IMAGE_NAME}:${VERSION}"
echo -e "   2. Para push: ./build-robust.sh --push"
echo -e "   3. Para deploy: ./scripts/deploy-with-onboarding-fix.sh" 