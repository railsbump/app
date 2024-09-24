# 👊 RailsBump

Check your Ruby gems for compatibility with all major Rails versions.

## Usage

The app is live at https://railsbump.org/, where you can check an [individual gem](http://railsbump.org/gems/new) or a [whole Bundler lockfile](http://railsbump.org/lockfiles/new) (Gemfile.lock).

## Behind the scenes

RailsBump uses a few approaches to check whether a gem version is compatible with a specific Rails release:

- if the gem version has a direct dependency on one of the "Rails gems" (rails, railties, activerecord, activesupport, etc.), it may be clear that it is not compatible with some Rails releases immediately
- if the gem version has a dependency on a specific version of another gem that we already know is not compatible with a Rails release, this gem version is not compatible either,
- if all other approaches don't work, RailsBump simply puts the gem version and a Rails release in a Gemfile and lets Bundler figure it out. If the gem can be successfully installed along with the Rails release, it counts as "compatible".

Since some gems have a lot of versions and each one needs to be checked against multiple Rails releases, this could get out of hand quickly. To minimize the amount of compatibility checks that need to be done, the gem versions are grouped by their dependencies first. If multiple versions (of the same gem or even of different gems) have the same dependencies, a single check is enough to determine whether all of them are compatible with a specific Rails release or not.

To actually perform the check, [GitHub Actions](https://github.com/features/actions) are used. For each check, a new branch is creted in a [separate repository](https://github.com/railsbump/checker), which triggers a [workflow](https://github.com/railsbump/checker/blob/main/.github/workflows/check.yml) that essentially tries to run `bundle lock` and reports the result back to the RailsBump app via a [webhook](https://docs.github.com/en/developers/webhooks-and-events/about-webhooks).

## History

RailsBump used to be called Ready4Rails until December 2019, when [Manuel Meurer](https://github.com/manuelmeurer) took over from [Florent Guilleux](https://github.com/Florent2) to automate the service that Ready4Rails had been doing more or less manually until then.

The relaunch took longer than expected, mainly because of the Coronavirus pandemic, and the first usable version of RailsBump was finally launched in August 2020.

## Stats

You can see live stats from Plausible Analytics here: https://plausible.io/railsbump.org

## Contributing

If you notice a bug or have an idea for an improvement, please open an [issue](https://github.com/railsbump/app/issues/new) or submit a [PR](https://github.com/railsbump/app/pulls).

If you'd like to get involved in the development, get in touch [via email](mailto:hello@railsbump.org)!

### Setup 

You will need these services:

- Postgres 16 or higher
- Redis

In order to set up the application locally: 

1. `git clone git@github.com:railsbump/app.git`
2. `bin/setup`
3. `foreman start -f Procfile.dev`
4. Go to http://localhost:3000

If these steps don't work, please submit a new issue: https://github.com/railsbump/app/issues/new

We recommend running these scheduled tasks:

- `bin/rails runner "Compats::CheckUnchecked.call"` once every 5 to 10 minutes

- `bin/rails runner "Maintenance::Hourly.call"` once an hour

## Support

If you find RailsBump useful and would like to support the ongoing development, [buy me a coffee](https://www.buymeacoffee.com/279lcDtbF) or [become a sponsor](https://github.com/sponsors/manuelmeurer)!

## License

This project is licensed under the MIT License - see the LICENSE.txt file for details.
