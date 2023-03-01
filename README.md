# Mention group bot
Чат-бот, который умеет тегать по группам

## Запуск для разработки
```
  bundle

  echo "export DATABASE_USERNAME=YOUR_USERNAME\nexport DATABASE_PASSWORD=YOUR_PASSWORD\nexport TELEGRAM_TOKEN=YOUR_TOKEN" > .env

  source .env

  rails telegram:bot:poller
```

## Запуск

Переменные для запуска через docker compose должны быть в файле `.production.env`

```
  POSTGRES_USER=your_user
  POSTGRES_PASSWORD=your_password
  DATABASE_HOST=database
  DATABASE_USERNAME=your_user
  DATABASE_PASSWORD=your_password
  TELEGRAM_TOKEN=your_token
  BOT_HOST=your_host
  RAILS_MASTER_KEY=your_master_key
  REDIS_URL=redis://redis:6379/1
```

Далее запускаем через `docker compose`

```
  docker compose up -d
```
