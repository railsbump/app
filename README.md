# 👊 RailsBump

Check your Ruby gems for compatibility with all major Rails versions.

## Usage

The app is live at https://railsbump.org/, where you can check an [individual gem](http://railsbump.org/gems/new) or a [whole Bundler lockfile](http://railsbump.org/lockfiles/new) (Gemfile.lock).

## Behind the scenes

RailsBump checks whether a gem version is compatible with a specific Rails release by simply puting both of them in a Gemfile and letting Bundler figure it out. If the gem can be successfully installed along with the Rails release, it counts as 'compatible'.

Since some gems have a lot of versions and each one needs to be checked against multiple Rails releases, this could get out of hand quickly. To minimize the amount of compatibility checks that need to be done, the gem versions are grouped by their dependencies first. If multiple versions (of the same gem or even of different gems) have the same dependencies, a single check is enough to determine whether all of them are compatible with a specific Rails release or not.

To actually perform the check, [GitHub Actions](https://github.com/features/actions) are used. For each check, a new branch is creted in a [separate repository](https://github.com/manuelmeurer/railsbump-checker), which triggers a [workflow](https://github.com/manuelmeurer/railsbump-checker/blob/main/.github/workflows/ci.yml) that essentially tries to run `bundle lock` and reports the result back to the RailsBump app via a [webhook](https://docs.github.com/en/developers/webhooks-and-events/about-webhooks).

## History

RailsBump used to be called Ready4Rails until December 2019, when [Manuel Meurer](https://github.com/manuelmeurer) took over from [Florent Guilleux](https://github.com/Florent2) to automate the service that Ready4Rails had been doing more or less manually until then.
The relaunch took longer than expected, mainly because of the Coronavirus pandemic, and the first usable version of RailsBump was finally launched in August 2020.

## Contributing

If you notice a bug or have an idea for an improvement, please open an [issue](https://github.com/manuelmeurer/railsbump/issues/new) or submit a [PR](https://github.com/manuelmeurer/railsbump/pulls).

If you'd like to get involved in the development, get in touch [via email](mailto:hello@railsbump.org)!

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.
