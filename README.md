## Быстрый старт с Docker

1. Установите [Docker](https://docs.docker.com/get-docker/) и [pnpm](https://pnpm.io/installation)

2. Соберите и запустите контейнер:
```bash
cd server

# Установите pnpm глобально (если не установлен)
npm install -g pnpm

# Сборка и запуск
pnpm docker:build
pnpm docker:up
```

3. Проверьте статус сервиса:
```bash
docker-compose ps
```

## Основные команды (сервер)

```bash
# Локальная разработка
pnpm dev

# Production сборка
pnpm build && pnpm start

# Docker-операции
pnpm docker:build  # Сборка образа
pnpm docker:up     # Запуск контейнера
docker-compose logs -f # Просмотр логов
```

## Переменные окружения Docker

Создайте `.env` файл в папке server:
```env
JWT_SECRET=your_strong_secret
PORT=3000
```

И обновите docker-compose.yml для использования файла:
```yaml
env_file:
  - .env
```