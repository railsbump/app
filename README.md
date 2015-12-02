# Is this gem ready for Rails 4 or 5?

[Ready4Rails.net](http://www.ready4rails.net) lists many gems and shows whether they are ready
for Rails 4 or 5. You can also paste your Gemfile to get a one-click report of the status of your Gemfile gems.

## API (Beta)

[Ready4Rails.net](http://www.ready4rails.net) gives an API to programatically check if a given
gem is ready for Rails 4 or 5. (Please note this feature is still in beta and can be changed in future)

Syntax
-----------

Request (GET)

```ruby
http://ready4rails.net/gems/<gem name>
```

response
```ruby
  JSON object with gem details
```

E.g:

```ruby
#request (GET)

http://localhost:3000/gems/devise.json

#response
{"id":1,"name":"devise","status_rails4":"ready","notes_rails4":"ready","created_at":"2015-12-01T23:02:37.019Z","updated_at":"2015-12-01T23:02:37.019Z","status_rails5":"unknown","notes_rails5":""}
```


## Thanks to

* all the people who report new gem statuses and add new gems to the site
* [Amar Raja](https://github.com/amarraja) for implementing the feature allowing the users to paste their Gemfiles

## Authors

* [frodsan](https://github.com/frodsan)
* [Florent2](https://github.com/Florent2)

## License

This project is licensed under the terms of the MIT license.
