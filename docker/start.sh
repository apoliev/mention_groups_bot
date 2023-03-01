#!/bin/sh

bundle exec rails db:create
bundle exec rails db:migrate

bundle exec rails telegram:bot:delete_webhook
bundle exec rails telegram:bot:set_webhook

bundle exec rails s
