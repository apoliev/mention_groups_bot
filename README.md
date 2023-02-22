# Mention group bot
Чат-бот, который умеет тегать по группам

## Запуск для разработки
```
  bundle

  echo "export DATABASE_USERNAME=YOUR_USERNAME\nexport DATABASE_PASSWORD=YOUR_PASSWORD\nexport TELEGRAM_TOKEN=YOUR_TOKEN" > .env

  source .env

  rails telegram:bot:poller
```
