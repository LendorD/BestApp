DATABASE_URL ?= postgres://gamementor:gamementor@localhost:5432/gamementor?sslmode=disable

.PHONY: run test tidy build docker-up docker-down migrate-up migrate-down migrate-create recorder-run frontend-get frontend-run frontend-run-api frontend-stop frontend-build frontend-analyze

run:
	go run ./cmd/api

test:
	go test ./...

tidy:
	go mod tidy

build:
	go build ./cmd/api

docker-up:
	docker compose up --build

docker-down:
	docker compose down

migrate-up:
	migrate -path migrations -database "$(DATABASE_URL)" up

migrate-down:
	migrate -path migrations -database "$(DATABASE_URL)" down

migrate-create:
	migrate create -ext sql -dir migrations -seq $(name)

recorder-run:
	go run ./cmd/recorder

frontend-get:
	cd frontend && flutter pub get

frontend-run:
	cd frontend && flutter run -d chrome --web-port 5173

frontend-run-api:
	cd frontend && flutter run -d chrome --web-port 5173 --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=http://localhost:8080/api/v1

frontend-stop:
	powershell -NoProfile -Command "$$pids = Get-NetTCPConnection -LocalPort 5173 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique; if ($$pids) { Stop-Process -Id $$pids -Force }"

frontend-build:
	cd frontend && flutter build web

frontend-analyze:
	cd frontend && flutter analyze
