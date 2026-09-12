# Triagent

Rails 8 security-finding workspace for importing labeled GitHub issues and routing them through vulnerability review.

## Local setup

1. Install and start PostgreSQL, then create a database named `sentinel_development` (or set `DATABASE_URL`).
2. Copy `.env.example` into your local environment and set `JWT_SECRET`, `INTERNAL_INGEST_TOKEN`, and the GitHub values.
3. Run `bundle install`, `bin/rails db:prepare`, and `bin/rails db:seed`.
4. Start the web server with `bin/rails server`; start workers with `bin/jobs start` in a second terminal.

Development login: `admin@acme.test` / `Password123!`.

## API

`POST /api/v1/auth/login` returns a Bearer token. With `Authorization: Bearer TOKEN`, use:

- `GET /api/v1/vulnerabilities`
- `POST /api/v1/vulnerabilities`
- `PATCH /api/v1/vulnerabilities/:id` (including multipart `full_assessment` PDF uploads)
- `PATCH /api/v1/vulnerabilities/:id/archive`

The scheduled `PollGithubSecurityIssuesJob` runs every 8 hours in production. It reads only GitHub issues with the `security` label and POSTs them to the protected internal import endpoint. Imports are deduplicated by GitHub issue URL.

To run an import immediately after the web server is available, use `bin/rails github:import_security_issues`. Set `APP_URL` to that server's full URL (for example, `http://localhost:3000`), and provide a PAT with read access to the configured public or private repository. The scheduled job uses the same path every eight hours.

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
