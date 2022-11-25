FROM elixir:latest

RUN apt-get update -qq && \
    apt-get install -y build-essential vim inotify-tools && \
    mix local.hex --force

ENV APP_HOME /messages_poc
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY mix* $APP_HOME/
RUN mix deps.get
COPY . $APP_HOME
EXPOSE 4000
CMD ["/messages_poc/docker-startup.sh"]
