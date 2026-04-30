# API: `poll_after_seconds` heuristic

## Context

`POST /lockfiles` (api subdomain) creates a `Lockfile`, enqueues an async
compatibility check, and returns `202 Accepted` with a `Retry-After` header
plus a `retry_after_seconds` body field. This value tells API consumers
(humans, scripts, AI agents) how long to wait before polling
`GET /lockfiles/:slug`.

The estimate has to balance two failure modes:

- **Under-estimating** → consumer polls too early, gets `status: "pending"`,
  and has to retry. Wastes a request on every consumer, and confuses AI
  agents that take the value as gospel.
- **Over-estimating** → consumer waits longer than necessary, increases
  perceived latency, and (for AI agents) burns cycles on idle waits.

We err on the side of slight over-estimation: a wasted poll is more
annoying than a few extra seconds of waiting.

## Calculation

Implemented in `API::LockfilesController#poll_after_seconds`:

```ruby
PER_GEM_SECONDS = 2
MIN_POLL_SECONDS = 30
MAX_POLL_SECONDS = 600

def poll_after_seconds(lockfile)
  concurrency = ENV.fetch("SIDEKIQ_CONCURRENCY", 2).to_i.clamp(1, 25)
  estimate = (lockfile.gems.size * PER_GEM_SECONDS.to_f / concurrency).ceil
  estimate.clamp(MIN_POLL_SECONDS, MAX_POLL_SECONDS)
end
```

The mental model:

```
estimate = (gems / Sidekiq concurrency) * per-gem cost
```

- `gems` — number of gems parsed from the submitted Gemfile.lock,
  excluding `rails` itself.
- `concurrency` — Sidekiq workers available to process `Checks::ResolveGem`
  jobs in parallel. Production runs with `SIDEKIQ_CONCURRENCY=2`.
- `PER_GEM_SECONDS` — average time one gem check takes (subprocess
  bundler resolution).

Clamped to a sensible range so trivially small lockfiles still return a
reasonable poll cadence (no one wants `Retry-After: 1`) and pathological
ones don't suggest "come back tomorrow."

## Why these constants

### `PER_GEM_SECONDS = 2`

Picked from two dev benchmarks that agreed on ~1.35s/gem real cost
(41-gem fixture finished in 28s; 182-gem real-world lockfile finished
in 123s, both at concurrency=2). Setting the constant to 2 leaves a
~50% buffer for production variance (slower dynos, slower gems with
heavy dependency graphs) without grossly over-estimating like the
initial 5 did. Re-tune once we have production timing data.

### `MIN_POLL_SECONDS = 30`

Floor for tiny lockfiles. Even a 2-gem lockfile takes a few seconds end-
to-end (Sidekiq pickup, subprocess startup, DB writes). Telling a client
to come back in 3 seconds invites a polling storm. 30 seconds is a humane
default cadence for retry-after.

### `MAX_POLL_SECONDS = 600`

Ceiling = 10 minutes. Past this, the consumer should suspect something is
wrong and surface that to the user. With concurrency=2 and
`PER_GEM_SECONDS=2`, this corresponds to a ~600-gem lockfile — covers
typical Rails apps (30–80 gems) and even most large ones (80–200 gems).
Outliers like Mastodon or Discourse (200–400+ gems) hit this ceiling, but
those are rare (<5% of submissions).

### Concurrency clamp `clamp(1, 25)`

Defensive guard. Sidekiq supports much higher concurrency, but the per-
job DB / subprocess work means real parallelism plateaus before that.
Capping at 25 keeps the divisor sane if someone mis-sets the env var.

## How to tune

1. Use `bin/api_benchmark <Gemfile.lock>` (local-only, gitignored) to
   submit a real lockfile and measure actual completion time.
2. Compute the implied `PER_GEM_SECONDS = actual_seconds * concurrency / gems`.
3. Multiply by ~2 to get a conservative buffer (different gems vary; you
   don't want to under-estimate the slow ones).
4. Update the constant; ship.

For a more rigorous fix later, record `started_at` / `completed_at` on
each `gem_check`, compute a rolling average per gem, and replace the
constant with that.

## Distribution of Gemfile sizes

Sample sizing to keep in mind when tuning:

| Size | Deps | Frequency |
|---|---|---|
| Library / gem | 5–30 | common (gem authors checking compat) |
| Typical Rails app | 30–80 | most submissions |
| Large SaaS | 80–200 | mid-size company codebases |
| Outlier (Mastodon, Discourse, GitLab) | 200–400+ | <5% |

Tune for the 30–80 band. Outliers will hit `MAX_POLL_SECONDS` and that's
fine.
