# Variáveis
COMPOSE_FILE=docker-compose.yml
DB_CONTAINER=taskly_db
DB_NAME=taskly
DB_USER=taskly

# ------------------------------------------
# Serviços básicos
# ------------------------------------------

up:
	@echo "🚀 Subindo containers do Docker..."
	docker compose -f $(COMPOSE_FILE) up -d
	@echo "⏳ Aguardando Postgres iniciar..."
	until docker exec $(DB_CONTAINER) pg_isready -U $(DB_USER) > /dev/null 2>&1; do \
		printf "."; \
		sleep 1; \
	done
	@echo "\n✅ Postgres está pronto!"
	@echo "📦 Rodando migrations do Prisma..."
	npx pnpm --filter @taskly/api exec prisma migrate dev --name init
	@echo "🎉 Ambiente pronto e migrations aplicadas!"

down:
	docker compose -f $(COMPOSE_FILE) down
