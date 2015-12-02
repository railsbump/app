# Is this gem ready for Rails 4 or 5?

[Ready4Rails.net](http://www.ready4rails.net) lists many gems and shows whether they are ready
for Rails 4 or 5. You can also paste your Gemfile to get a one-click report of the status of your Gemfile gems.

## API (Beta)

[Ready4Rails.net](http://www.ready4rails.net) gives a JSON API to programatically check if a given
gem is ready for Rails 4 or 5. (Please note this feature is still in beta and can be changed in future)

Request (GET)

```ruby
http://www.ready4rails.net/gems/<gem name>.json
```

Response
```ruby
  JSON object with gem details
```

Example:

```ruby
> require 'open-uri'
> JSON.parse open('http://www.ready4rails.net/gems/devise.json').read
=> {"id"=>962, "name"=>"devise", "status_rails4"=>"ready", "notes_rails4"=>"from gem version 3.0.0", "created_at"=>"2013-06-27T20:22:29.132Z", "updated_at"=>"2013-07-20T16:08:05.965Z", "status_rails5"=>"unknown", "notes_rails5"=>nil}
```

## Thanks to

* all the people who report new gem statuses and add new gems to the site
* [Sameera Gayan](https://github.com/sameera207) for improving the test suite and building the API
* [Amar Raja](https://github.com/amarraja) for implementing the feature allowing the users to paste their Gemfiles

## Authors

* [frodsan](https://github.com/frodsan)
* [Florent2](https://github.com/Florent2)

## Development

* run test suite with `bin/rspec`

## License

This project is licensed under the terms of the MIT license.
