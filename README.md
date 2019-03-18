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

### MongoDB

```bash
% docker run -it --rm --name mongodb -p 27017:27017 mongo:latest
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

```bash
$ iex -S mix
```
