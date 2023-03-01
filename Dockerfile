FROM ruby:3.1-alpine

ENV RAILS_ENV=production
ENV APP_HOME=/app
ENV PORT=3000

WORKDIR $APP_HOME

RUN apk add --no-cache tzdata postgresql-dev nodejs g++ make vim
RUN gem install bundler -v 2.4.3

COPY Gemfile* $APP_HOME/

RUN bundle install

COPY . $APP_HOME

EXPOSE $PORT

CMD /app/docker/start.sh
