# Phlex::Chatbot

TODO: Delete this and the text below, and describe your gem

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/phlex/chatbot`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

TODO: Replace `phlex-chatbot` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add phlex-chatbot

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install phlex-chatbot

Next, you need to mount the chatbot app into your Rack application in order to get the CSS and JS for these
components.

In Rails, update your `config/routes.rb` file by adding:

    $ mount Phlex::Chatbot::Web, at: "/phlex-chatbot"

In other Rack applications, you might do something like the following or consult your framework's
specific instructions for mounting Rack apps:

```ruby
  map 'phlex-chatbot' do
    use Phlex::Chatbot::Web
  end
```

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

While you are actively developing you'll likely want to watch for asset changes:

    $ WATCH=1 bin/build

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hedgeyedev/phlex-chatbot.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
