FROM ruby:3.4.2
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-client
RUN groupadd -g 1000 dev-user && useradd -u 1000 -g 1000 -m dev-user
RUN mkdir /home/dev-user/myapp
WORKDIR /home/dev-user/myapp
COPY ./Gemfile /home/dev-user/myapp/Gemfile
COPY ./Gemfile.lock /home/dev-user/myapp/Gemfile.lock
RUN bundle install