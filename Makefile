BACKEND_DIR ?= backend
FRONTEND_DIR ?= frontend
DATABASE_URL ?= postgres://gamementor:gamementor@localhost:5432/gamementor?sslmode=disable
FRONTEND_PORT ?= 5174
API_BASE_URL ?= http://localhost:8080/api/v1
DEFAULT_DOTA_ACCOUNT_ID ?= 369102305

.PHONY: run test tidy build docker-up docker-down docker-backend-up docker-frontend-up migrate-up migrate-down migrate-create recorder-run backend-run backend-test backend-tidy backend-build frontend-get frontend-run frontend-run-api frontend-stop frontend-build frontend-analyze frontend-test

run: backend-run

test: backend-test frontend-test

tidy: backend-tidy

build: backend-build frontend-build

backend-run:
	cd $(BACKEND_DIR) && go run ./cmd/api

backend-test:
	cd $(BACKEND_DIR) && go test ./...

backend-tidy:
	cd $(BACKEND_DIR) && go mod tidy

backend-build:
	cd $(BACKEND_DIR) && go build ./cmd/api

docker-up:
	docker compose up --build

docker-down:
	docker compose down

docker-backend-up:
	docker compose up --build postgres migrate backend

docker-frontend-up:
	docker compose up --build frontend

migrate-up:
	migrate -path $(BACKEND_DIR)/migrations -database "$(DATABASE_URL)" up

migrate-down:
	migrate -path $(BACKEND_DIR)/migrations -database "$(DATABASE_URL)" down

migrate-create:
	migrate create -ext sql -dir $(BACKEND_DIR)/migrations -seq $(name)

recorder-run:
	cd $(BACKEND_DIR) && go run ./cmd/recorder

frontend-get:
	cd $(FRONTEND_DIR) && flutter pub get

frontend-run:
	cd $(FRONTEND_DIR) && flutter run -d chrome --web-port $(FRONTEND_PORT)

frontend-run-api:
	cd $(FRONTEND_DIR) && flutter run -d chrome --web-port $(FRONTEND_PORT) --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=$(API_BASE_URL) --dart-define=DEFAULT_DOTA_ACCOUNT_ID=$(DEFAULT_DOTA_ACCOUNT_ID)

frontend-stop:
	powershell -NoProfile -Command "$$pids = Get-NetTCPConnection -LocalPort $(FRONTEND_PORT) -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique; if ($$pids) { Stop-Process -Id $$pids -Force }"

frontend-build:
	cd $(FRONTEND_DIR) && flutter build web --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=$(API_BASE_URL) --dart-define=DEFAULT_DOTA_ACCOUNT_ID=$(DEFAULT_DOTA_ACCOUNT_ID)

frontend-analyze:
	cd $(FRONTEND_DIR) && flutter analyze

frontend-test:
	cd $(FRONTEND_DIR) && flutter test
