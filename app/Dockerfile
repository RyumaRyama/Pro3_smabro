# FROM ruby:latest
#
# # ENV WORK="/app"
#
# RUN mkdir /app
# COPY . /app
# WORKDIR /app
#
# EXPOSE 4567
#
# RUN gem install bundler \
#     && bundle install --deployment --path vender/bundle
#
# # ENV PATH=
#
# CMD ["ruby", "--version"]

FROM ruby:2.6

RUN mkdir /app
ADD . /app
WORKDIR /app

RUN gem install bundler \
    && bundle install

EXPOSE 4567
CMD ["bundle", "exec", "ruby", "app.rb", "-o0.0.0.0"]

