# `bin/api_check_lockfile`

Small wrapper around `curl` for hitting the RailsBump compatibility API
without writing the JSON body by hand.

## Prerequisites

- A running RailsBump app (locally: `bin/dev`).
- `jq` installed (`brew install jq`).
- For local use, `api.localhost` resolves to `127.0.0.1` on macOS by
  default. The dev environment forces `tld_length = 0` so Rails treats
  `api.localhost` as having subdomain `api` (see
  `config/environments/development.rb`).

## Submit a Gemfile.lock

```sh
bin/api_check_lockfile spec/fixtures/Gemfile.lock
```

Sends the file's contents as the `lockfile.content` field in a
`POST /lockfiles` request, then pretty-prints the JSON response:

```json
{
  "slug": "abc123…",
  "status": "pending",
  "status_url": "http://api.localhost:3000/lockfiles/abc123…",
  "retry_after_seconds": 103,
  "message": "Compatibility check is running. Wait ~103 seconds, then GET …"
}
```

The compatibility check runs asynchronously in Sidekiq. Use the slug
to fetch results once the suggested wait elapses.

## Fetch results for an existing slug

```sh
bin/api_check_lockfile --show abc123…
```

Issues `GET /lockfiles/:slug` and pretty-prints:

```json
{
  "slug": "abc123…",
  "status": "pending",
  "lockfile_checks": [
    {
      "target_rails_version": "7.2",
      "ruby_version": "3.3.0",
      "bundler_version": "2.5.0",
      "rubygems_version": "3.5.0",
      "status": "pending",
      "gem_checks": [
        {
          "name": "puma",
          "locked_version": "6.4.0",
          "status": "complete",
          "result": "compatible",
          "earliest_compatible_version": null,
          "error_message": null
        }
      ]
    }
  ]
}
```

### Status values

Top-level `status` (and each `lockfile_check.status`) is one of:

- `"pending"` — work remains. Keep polling (honor `retry_after_seconds` /
  the `Retry-After` header).
- `"complete"` — every gem reached a terminal state. Terminal, stop polling.

Failure is tracked per gem, not per lockfile: each `gem_check.status` is
`"pending"`, `"complete"`, or `"failed"`. A gem is marked `"failed"` when
it could not be resolved after the checker exhausted its retries. The
surrounding `lockfile_check` still becomes `"complete"` once every gem is
terminal, so a completed check can contain individual `"failed"` gems
alongside resolved ones. Inspect `gem_check.status` / `gem_check.result`
for per-gem outcomes.

## Hitting a non-local environment

Set `API_HOST`:

```sh
API_HOST=api.railsbump.org bin/api_check_lockfile path/to/Gemfile.lock
```

Scheme auto-selects based on the host: `http` for `localhost`/`127.0.0.1`,
`https` for everything else. Override with `API_SCHEME` only if needed
(e.g. hitting a remote host over plain HTTP for debugging):

```sh
API_HOST=staging.example.com API_SCHEME=http \
  bin/api_check_lockfile path/to/Gemfile.lock
```

## Polling pattern

A typical end-to-end flow from the shell:

```sh
SLUG=$(bin/api_check_lockfile path/to/Gemfile.lock | jq -r '.slug')
sleep 60
bin/api_check_lockfile --show "$SLUG"
```

For more rigorous timing, see the gitignored `bin/api_benchmark` helper
(documented in `docs/api-poll-after-seconds.md`).
