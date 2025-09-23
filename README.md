# Blueprint

Hey! Welcome to the codebase for Hack Club Blueprint. Blueprint is a YSWS program to build hardware. You can find more details on [blueprint.hackclub.com](https://blueprint.hackclub.com?utm_source=github&utm_medium=readme).

## Local Development Setup

### 1. Prerequisites

- Ruby (see `.ruby-version` or Gemfile)
- Bundler (`gem install bundler`)
- Docker (for running Postgres)

### 2. Set up environment variables

- Copy `.env.development.example` to `.env` and fill in the required values.

### 3. Start Postgres with Docker

You can spin up a local Postgres instance using Docker:

```sh
docker run -d \
  --name blueprint-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=[REDACTED:password] \
  -e POSTGRES_DB=blueprint_development \
  -p 5432:5432 \
  postgres:15
```

### 4. Install dependencies

```sh
bundle install
```

### 5. Setup the database

```sh
bin/rails db:setup
```

### 6. Start the Rails server

```sh
bin/dev
```
