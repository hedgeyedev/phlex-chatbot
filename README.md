# Phlex::Chatbot

This is a Rack-based chatbot with an implmentation-agnostic chat backend. Add it to your Gemfile, and
with a little bit of code you'll be on your way to integrating chat into your Ruby app.

There are two main components for chatting: a component designed to act as a responsive sidebar and a
component you can use in fullscreen fashion.

## Installation

Install the gem and add it to your application's Gemfile by executing:

    $ bundle add phlex-chatbot

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install phlex-chatbot

## Usage

You will need to mount the chatbot app into your Rack application, which will differ depending on your
host app's configuration.

In Rails, update your `config/routes.rb` file by adding:
```ruby
mount Phlex::Chatbot::Web, at: "/phlex-chatbot"
```

Create an initializer `config/initializers/phlex_chatbot.rb` to set your logger:
```ruby
Phlex::Chatbot.logger = Rails.logger
Phlex::Chatbot.conversator = ... <a subclass of Phlex::Chatbot::Conversator, see below>
Phlex::Chatbot.disallow_error_messages! # if you don't want Ruby error messages shown in the bot UI (default)
Phlex::Chatbot.allow_error_messages! # if you want Ruby error messages shown in the bot UI
```

In other Rack applications, you might do something like the following or consult your framework's
specific instructions for mounting Rack apps:

```ruby
map 'phlex-chatbot' do
  use Phlex::Chatbot::Web
end
```

The path at which you host the chatbot is up to you, here we've named it `phlex-chatbot`. Somewhere in
your application you will need to render the chatbot:

```ruby
render Phlex::Chatbot::Chat::SidebarComponent.new(
  conversation_token: token,
  endpoint: "/phlex-chatbot",
)
```

```ruby
render Phlex::Chatbot::Chat::FullScreenComponent.new(
  conversation_token: token,
  endpoint: "/phlex-chatbot",
)
```

The chat components receive the same set of arguments:
1. `conversation_token` - the token received when creating your chatbot conversation (see below)
1. `endpoint` - the route at which you are hosting the chatbot (e.g. `/phlex-chatbot`)
1. `messages` - any messages you want to seed the chatbot with (i.e. an initial message for any session,
   or a history of messages if your application maintains such a thing)

### Conversations

To allow your users to have a conversation with the chatbot, your app will need to get a token:

```ruby
token = Phlex::Chatbot::Switchboard.create(user.email_address)
```

Here we are passing the email address of a `User` in the system as the application's identifier for this
conversation. The chatbot will encrypt and store that identifier and return the unique token to you. Later,
your application can use that token to interact with the chatbot: send it messages or status information,
and eventually terminate the conversation.

Your application is responsible for determining how to respond to that new message. Here is an example that
sends the chatbot a status message, processes the incoming message using `langchainrb` and `ruby-openai`, and
finally sends a final response.

Your application is responsible for setting the `Phlex::Chatbot.conversator` which is a subclass of
`Phlex::Chatbot::Conversator`. At a minimum, you should implement `#call(bot, incoming_message, bot_id)`.
You can also implement the `#contextualize` message that is responsible for adding more context to the mesasge
that gets sent to the bot's UI. Specifically, it should add the `user_name` and `avatar` keys to the message
hash (as symbols) based on whether the message is from the bot or the person with whom the bot is conversing.
The base implementation adds some basic defaults.

```ruby
Phlex::Chatbot.conversator = Class.new(Phlex::Chatbot::Conversator) do
  def call(bot, incoming_message, bot_id)
    bot.send_status!(message: "I got your message, just a sec...")

    llm  = Langchain::LLM::OpenAI.new(api_key: ENV["OPENAI_API_KEY"])
    chat = llm.chat(messages: [{ role: user.type, content: incoming_message }])

    bot.send_response!(message: chat.chat_completion)
  end
end
Phlex::Chatbot::Switchboard.create(user.email)
```

This example uses a custom class and the excellent [Sequel](https://sequel.jeremyevans.net/) library to do a
full text search for the top 10 results matching the incoming message.

```ruby
class FullTextSearch < Phlex::Chatbot::Conversator
  SYSTEM_NAME = 'My Bot'

  def call(bot, incoming_message, bot_id)
    bot.send_status!(message: "Compiling results...")

    terms = parse_terms(incoming_message)
    if terms.empty?
      bot.send_failure!(message: "you need to give me some terms")
    else
      results = DB[:fluberties].full_text_search(:borts, terms, rank: true).limit(10).select_map(:blobbities)
      bot.send_response!(message: results.join(". "))
    end
  end

  def contextualize(hash)
    hash.merge!(user_name: SYSTEM_NAME) unless hash[:from_user]
    hash
  end

  def self.parse_terms(incoming_message)
    CSV.parse_line(incoming_message).compact.map(&:strip)
  rescue
    []
  end
end

Phlex::Chatbot::Switchboard.create(user.email)
```

You can converse with your chatbot in three ways:
1. `#send_status!` - sends a status message that is displayed at the top of the bot's temporary response
1. `#send_response!` - sends a final message that replace's the bot's temporary response
1. `#send_failure!` - similar to `#send_response!` this will replace the bot's temporary response but allows
   the UI to style the response differently, indicating to the user that something unexpected has occured

### Channel#send_status!
This message receives a `String` which is broadcast to all chat subscribers. The chatbot will change the title
of the bot response placeholder with this message. It is expected that the "backend" will either broadcast
a final response or a failure at some point after this.

### Channel#send_response!
This message receives `message: String` and `sources: Array<String>`.
  - `message: String` - the message you want to broadcast to all chat subscribers. Sources can be link with the
    pattern `[1]`, `[2]`, `[3]`, etc. These text patterns will be replaced with the corresponding source from
    the `sources` argument, if supplied. The links are one-based, not zero-based.
  - `sources: Array<String>` - links to source data in the `message`

### Channel#send_failure!
This message receives an Exception object. Its `message` is broadcast to all chat subscribers. This will cause
the chatbot placeholder to be finalized with this message. No other response is needed after this point.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update
the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for
the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

While you are actively developing you'll likely want to watch for asset changes:

    $ npm run watch-all

### Building new versions

1. edit `lib/phlex/chatbot/version.rb`
1. run `bundle install` (which will update the version in Gemfile.lock)
1. commit
1. tag with new version
1. push
1. create a release in GitHub

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hedgeyedev/phlex-chatbot.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
