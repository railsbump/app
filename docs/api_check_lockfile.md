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

Top-level `status` flips to `"complete"` once every nested
`gem_check.status` is `"complete"`.

## Hitting a non-local environment

Set `API_HOST` (and optionally `API_SCHEME`):

```sh
API_HOST=api.railsbump.org API_SCHEME=https \
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
