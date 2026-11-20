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
