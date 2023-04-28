# Mention group bot
Chatbot that can tag by groups

## Launch for development
```
  bundle

  echo "export DATABASE_USERNAME=YOUR_USERNAME\nexport DATABASE_PASSWORD=YOUR_PASSWORD\nexport TELEGRAM_TOKEN=YOUR_TOKEN" > .env

  source .env

  rails db:create db:migrate

  rails telegram:bot:poller
```

## Start

Variables to run via docker compose should be in `.production.env` file

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

Next, run through `docker compose`

```
  docker compose up -d
```
