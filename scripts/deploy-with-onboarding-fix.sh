#!/bin/bash

# Script de Deploy com Correção Automática de Onboarding
# Para versões customizadas do Chatwoot

set -e

# Configurações
IMAGE_NAME="seu-registry/chatwoot-custom"
COMPOSE_FILE="docker-compose.custom.yaml"
BACKUP_DIR="./backups"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Deploy com Correção Automática de Onboarding${NC}"

# Função para verificar se o comando existe
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Verificar dependências
if ! command_exists docker; then
  echo -e "${RED}❌ Docker não encontrado. Instale o Docker primeiro.${NC}"
  exit 1
fi

if ! command_exists docker-compose; then
  echo -e "${RED}❌ Docker Compose não encontrado. Instale o Docker Compose primeiro.${NC}"
  exit 1
fi

# Verificar se o arquivo .env existe
if [ ! -f .env ]; then
  echo -e "${YELLOW}⚠️  Arquivo .env não encontrado!${NC}"
  echo -e "${BLUE}📋 Copiando .env.example para .env...${NC}"
  cp .env.example .env
  echo -e "${YELLOW}⚠️  Configure as variáveis no arquivo .env antes de continuar${NC}"
  echo -e "${BLUE}📝 Variáveis importantes para onboarding:${NC}"
  echo -e "   - SECRET_KEY_BASE"
  echo -e "   - FRONTEND_URL"
  echo -e "   - DATABASE_URL ou POSTGRES_*"
  echo -e "   - REDIS_URL"
  exit 1
fi

# Backup do banco (se solicitado)
if [ "$1" = "--backup" ]; then
  echo -e "${YELLOW}📦 Criando backup do banco...${NC}"
  mkdir -p "$BACKUP_DIR"
  docker-compose -f "$COMPOSE_FILE" exec -T postgres pg_dump -U postgres chatwoot > "$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sql"
  echo -e "${GREEN}✅ Backup criado!${NC}"
fi

# Pull da imagem mais recente
echo -e "${YELLOW}📥 Baixando imagem mais recente...${NC}"
docker pull "$IMAGE_NAME:latest" || echo -e "${YELLOW}⚠️  Imagem não encontrada no registry, usando local${NC}"

# Deploy com zero downtime
echo -e "${YELLOW}🔄 Iniciando deploy...${NC}"
docker-compose -f "$COMPOSE_FILE" up -d --no-deps

# Aguardar aplicação ficar pronta
echo -e "${YELLOW}⏳ Aguardando aplicação ficar pronta...${NC}"
sleep 30

# Verificar se a aplicação está rodando
echo -e "${YELLOW}🔍 Verificando status da aplicação...${NC}"
if ! docker-compose -f "$COMPOSE_FILE" ps | grep -q "Up"; then
  echo -e "${RED}❌ Aplicação não está rodando. Verificando logs...${NC}"
  docker-compose -f "$COMPOSE_FILE" logs --tail=20
  exit 1
fi

# Health check
echo -e "${YELLOW}🔍 Verificando saúde da aplicação...${NC}"
for i in {1..10}; do
  if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Aplicação está funcionando!${NC}"
    break
  else
    echo -e "${YELLOW}⏳ Tentativa $i/10...${NC}"
    sleep 10
  fi
done

# Verificar e corrigir onboarding
echo -e "${BLUE}🔧 Verificando status do onboarding...${NC}"

# Executar diagnóstico do onboarding
docker-compose -f "$COMPOSE_FILE" exec -T chatwoot bundle exec rake onboarding:diagnose || {
  echo -e "${YELLOW}⚠️  Não foi possível executar diagnóstico do onboarding${NC}"
}

# Verificar se o onboarding deve ser mostrado
docker-compose -f "$COMPOSE_FILE" exec -T chatwoot bundle exec rake onboarding:check || {
  echo -e "${YELLOW}⚠️  Não foi possível verificar status do onboarding${NC}"
}

# Se não há usuários, forçar onboarding
echo -e "${BLUE}🔧 Verificando se é uma nova instalação...${NC}"
USER_COUNT=$(docker-compose -f "$COMPOSE_FILE" exec -T chatwoot bundle exec rails runner "puts User.count" 2>/dev/null || echo "0")

if [ "$USER_COUNT" = "0" ]; then
  echo -e "${YELLOW}📋 Nova instalação detectada (0 usuários)${NC}"
  echo -e "${BLUE}🔧 Habilitando onboarding...${NC}"
  docker-compose -f "$COMPOSE_FILE" exec -T chatwoot bundle exec rake onboarding:enable || {
    echo -e "${YELLOW}⚠️  Não foi possível habilitar onboarding automaticamente${NC}"
    echo -e "${BLUE}📝 Execute manualmente:${NC}"
    echo -e "   docker-compose -f $COMPOSE_FILE exec chatwoot bundle exec rake onboarding:enable"
  }
else
  echo -e "${GREEN}✅ Instalação existente detectada ($USER_COUNT usuários)${NC}"
fi

# Verificar logs finais
echo -e "${YELLOW}📋 Últimos logs da aplicação:${NC}"
docker-compose -f "$COMPOSE_FILE" logs --tail=10 chatwoot

echo -e "${GREEN}🎉 Deploy concluído com sucesso!${NC}"
echo -e "${GREEN}🌐 Acesse: http://localhost:3000${NC}"

# Instruções finais
echo -e "${BLUE}📋 Próximos passos:${NC}"
echo -e "   1. Acesse http://localhost:3000"
echo -e "   2. Se for nova instalação, complete o onboarding"
echo -e "   3. Se não aparecer onboarding, execute:"
echo -e "      docker-compose -f $COMPOSE_FILE exec chatwoot bundle exec rake onboarding:reset"
echo -e "   4. Para verificar status:"
echo -e "      docker-compose -f $COMPOSE_FILE exec chatwoot bundle exec rake onboarding:check" 