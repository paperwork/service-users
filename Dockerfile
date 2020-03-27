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
FROM elixir:1.10-alpine AS basic

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

# ---------------------------------------------------------------------------- #

FROM basic AS builder

ARG APP_NAME
ARG APP_VSN
ARG MIX_ENV=prod

ENV APP_NAME=${APP_NAME} \
    APP_VSN=${APP_VSN} \
    MIX_ENV=${MIX_ENV} \
    REPLACE_OS_VARS=true

WORKDIR /opt/build
COPY . .

RUN mix do deps.get, deps.compile, compile, release

# ---------------------------------------------------------------------------- #

FROM alpine:3.11 AS app

ARG APP_NAME
ARG APP_VSN
ARG MIX_ENV=prod

ENV APP_NAME=${APP_NAME} \
    APP_VSN=${APP_VSN} \
    MIX_ENV=${MIX_ENV} \
    REPLACE_OS_VARS=true

RUN apk update && \
    apk add --no-cache \
      bash \
      openssl-dev

WORKDIR /opt/app
COPY --from=builder /opt/build/_build/${MIX_ENV}/rel/${APP_NAME} .

CMD trap 'exit' INT; /opt/app/bin/${APP_NAME} start
