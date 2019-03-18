service-users
=============
Paperwork Users Service

## Prerequisites

### Docker

Get [Docker Desktop](https://www.docker.com/products/docker-desktop).

### Elixir/Erlang

On MacOS using [brew](https://brew.sh):

```bash
% brew install elixir
```

## Building

Fetching all dependencies:

```bash
% mix deps.get
```

Compiling:

```bash
% mix compile
```

## Running

First, we need a database. Let's run MongoDB on Docker:

```bash
% docker run -it --rm --name mongodb -p 27017:27017 mongo:latest
```

Second, we need to run [service-gatekeeper](https://github.com/paperwork/service-gatekeeper):

```bash
% cd service-gatekeeper/
% PORT=1337 JWT_SECRET='ru4XngBQ/uXZX4o/dTjy3KieL7OHkqeKwGH9KhClVnfpEaRcpw+rNvvSiC66dyiY' SERVICE_USERS="http://localhost:8880" ./target/debug/gatekeeper
```

Now we can run this service from within this cloned repository:

```bash
% iex -S mix
```
