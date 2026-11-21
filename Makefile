.PHONY: up down reset migrate test lint

-include .env
export

.env:
	sed "s/^APPROVAL_SIGNING_KEY=.*/APPROVAL_SIGNING_KEY=$$(openssl rand -hex 32)/" .env.example > .env

up:
	docker compose up -d --wait

down:
	docker compose down

reset:
	docker compose down -v

migrate:
	cd server && go run ./cmd/migrate

test:
	docker compose exec -T db psql -U $(POSTGRES_USER) -d postgres \
	-c 'DROP DATABASE IF EXISTS copilot_test WITH (FORCE)' -c 'CREATE DATABASE copilot_test'
	cd server && DATABASE_URL=$(TEST_DATABASE_URL) go run ./cmd/migrate
	cd server && go test -p 1 ./...

lint:
	test -z "$$(gofmt -l server)" || (gofmt -l server; exit 1)
	cd server && go vet ./...