# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                                                                            ║
# ║                 __ \             |               _|_) |                    ║
# ║                 |   |  _ \   __| |  /  _ \  __| |   | |  _ \               ║
# ║                 |   | (   | (      <   __/ |    __| | |  __/               ║
# ║                ____/ \___/ \___|_|\_\\___|_|   _|  _|_|\___|               ║
# ║                                                                            ║
# ║           * github.com/paperwork * twitter.com/paperworkcloud *            ║
# ║                                                                            ║
# ╚════════════════════════════════════════════════════════════════════════════╝
ARG ALPINE_VERSION=3.9
FROM elixir:1.10-alpine AS builder

ARG APP_NAME
ARG APP_VSN
ARG MIX_ENV=prod

ENV APP_NAME=${APP_NAME} \
    APP_VSN=${APP_VSN} \
    MIX_ENV=${MIX_ENV}

RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache \
    git \
    build-base && \
  mix local.rebar --force && \
  mix local.hex --force

WORKDIR /opt/app
COPY . .

RUN mix do deps.get, deps.compile, compile

RUN \
  mkdir -p /opt/built && \
  mix release && \
  cp _build/${MIX_ENV}/rel/${APP_NAME}/releases/${APP_VSN}/${APP_NAME}.tar.gz /opt/built && \
  cd /opt/built && \
  tar -xzf ${APP_NAME}.tar.gz && \
  rm ${APP_NAME}.tar.gz

FROM alpine:${ALPINE_VERSION}

ARG APP_NAME

RUN apk update && \
    apk add --no-cache \
      bash \
      openssl-dev

ENV REPLACE_OS_VARS=true \
    APP_NAME=${APP_NAME}

WORKDIR /opt/app
COPY --from=builder /opt/built .

CMD trap 'exit' INT; /opt/app/bin/${APP_NAME} foreground
