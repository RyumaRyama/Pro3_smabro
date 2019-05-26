FROM ruby:2.6.3

RUN mkdir /app
ADD . /app
WORKDIR /app

RUN gem install bundler \
    && bundle install

# ARG PORT
CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0"]
