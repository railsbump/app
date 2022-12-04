# syntax = docker/dockerfile:experimental

ARG RUBY_VERSION=3.1.2
ARG VARIANT=jemalloc-bullseye-slim
FROM quay.io/evl.ms/fullstaq-ruby:${RUBY_VERSION}-${VARIANT} as base

LABEL fly_launch_runtime="rails"

ARG BUNDLER_VERSION=2.3.26

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}

ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

ARG BUNDLE_WITHOUT=development:test
ARG BUNDLE_PATH=vendor/bundle
ENV BUNDLE_PATH ${BUNDLE_PATH}
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}

ARG REVISION
ENV REVISION=$REVISION

RUN mkdir /app
WORKDIR /app
RUN mkdir -p tmp/pids

RUN gem update --system --no-document && \
    gem install -N bundler -v ${BUNDLER_VERSION}

#######################################################################

# install packages only needed at build time

FROM base as build_deps

ARG BUILD_PACKAGES="git build-essential libpq-dev wget vim curl gzip xz-utils libsqlite3-dev"
ENV BUILD_PACKAGES ${BUILD_PACKAGES}

RUN --mount=type=cache,id=dev-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=dev-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y ${BUILD_PACKAGES} && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

#######################################################################

# install gems

FROM build_deps as gems

COPY Gemfile* ./
COPY .ruby-version ./
RUN bundle install && rm -rf vendor/bundle/ruby/*/cache

#######################################################################

# install deployment packages

FROM base

ARG DEPLOY_PACKAGES="git openssh-server postgresql-client file vim curl gzip libsqlite3-0"
ENV DEPLOY_PACKAGES=${DEPLOY_PACKAGES}

RUN --mount=type=cache,id=prod-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=prod-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y ${DEPLOY_PACKAGES} && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=gems /app /app
COPY --from=gems /usr/lib/fullstaq-ruby/versions /usr/lib/fullstaq-ruby/versions
COPY --from=gems /usr/local/bundle /usr/local/bundle

#######################################################################

# Deploy your application
COPY . .

# Adjust binstubs to run on Linux and set current working directory
RUN chmod +x /app/bin/* && \
    sed -i 's/ruby.exe\r*/ruby/' /app/bin/* && \
    sed -i '/^#!/aDir.chdir File.expand_path("..", __dir__)' /app/bin/*

# Run build task defined in lib/tasks/fly.rake
ARG BUILD_COMMAND="bin/rails fly:build"
RUN ${BUILD_COMMAND}

# Default server start instructions.  Generally Overridden by fly.toml.
ENV PORT 8080
ARG SERVER_COMMAND="bin/rails fly:server"
ENV SERVER_COMMAND ${SERVER_COMMAND}
CMD ${SERVER_COMMAND}
