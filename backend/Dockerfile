# Ruby on Rails Backend Dockerfile for Ebook Indexing Service
FROM ruby:3.2.2-slim

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  git \
  curl \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install bundler
RUN gem install bundler

# Copy Gemfile if exists
COPY Gemfile* ./

# Configure environment variables
ENV RAILS_ENV=production \
    BUNDLE_PATH=/usr/local/bundle \
    PORT=3000

EXPOSE 3000

# Default command to start server
CMD ["rails", "server", "-b", "0.0.0.0"]
