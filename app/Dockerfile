FROM ruby:2.6.3

RUN mkdir /app
ADD . /app
WORKDIR /app

RUN gem install bundler \
    && bundle install

EXPOSE 4567
