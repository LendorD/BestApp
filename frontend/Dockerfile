FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

ARG USE_MOCK_API=false
ARG API_BASE_URL=http://localhost:8080/api/v1
ARG DEFAULT_DOTA_ACCOUNT_ID=369102305

RUN flutter build web --release \
  --dart-define=USE_MOCK_API=${USE_MOCK_API} \
  --dart-define=API_BASE_URL=${API_BASE_URL} \
  --dart-define=DEFAULT_DOTA_ACCOUNT_ID=${DEFAULT_DOTA_ACCOUNT_ID}

FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
