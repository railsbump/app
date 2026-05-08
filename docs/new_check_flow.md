# `ENABLE_NEW_CHECK_FLOW` (a.k.a. `FeatureFlags.new_check_flow?`)

## What it is

A boolean env var that switches the lockfile-submission code path between the
legacy synchronous flow (gem-by-gem `Gemmy` records created up front) and the
new async flow (lockfile is queued, gems resolved by Sidekiq). Read through
[`FeatureFlags.new_check_flow?`](../lib/feature_flags.rb):

```ruby
ENV["ENABLE_NEW_CHECK_FLOW"] == "1"
```

Used by:

- `app/models/lockfile.rb` — skips the up-front `Gemmy` validation/build when on.
- `app/controllers/lockfiles_controller.rb` — swaps which checker is invoked.
- `app/views/gemmies/index.html.haml`, `app/views/shared/_header.html.haml` —
  hides legacy "Check a gem" UI when on.

## Default in development

**Always run dev with `ENABLE_NEW_CHECK_FLOW=1`.** The new flow is the path
exercised in production and in CI; running dev with it off means you're
testing the legacy flow that's being phased out.

`.env.sample` already includes:

```
ENABLE_NEW_CHECK_FLOW="1"
```

If you copied `.env.sample` to `.env` during setup (`cp .env.sample .env`),
foreman picks it up automatically when you run `bin/dev`. No further action
needed.

## How to verify it's active

```sh
bin/rails runner 'puts FeatureFlags.new_check_flow?'
# => true
```

If it prints `false`, your `.env` is missing the flag or the server was
started in a shell without it loaded.

## When to turn it off

Only when reproducing or fixing a regression in the legacy flow. Set
`ENABLE_NEW_CHECK_FLOW=0` (or remove the line) in `.env` and restart the
server. Flip it back on as soon as you're done.

## Production

Production sets `ENABLE_NEW_CHECK_FLOW=1` on the Heroku app config. Don't
toggle it without a heads-up — the two flows write different records.
