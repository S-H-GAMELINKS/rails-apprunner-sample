FROM ruby:3.1

RUN apt-get update && \
    apt-get install -y postgresql-client

WORKDIR /app

COPY . ./

RUN gem install bundler:2.3.13 && \
    bundle install

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
