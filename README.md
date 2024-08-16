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

    $ mount Phlex::Chatbot::Web, at: "/phlex-chatbot"

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
token = Phlex::Chatbot::BotConversation.create(user.email_address, callback)
```

Here we are passing the email address of a `User` in the system as the application's identifier for this
conversation. The chatbot will encrypt and store that identifier and return the unique token to you. Later,
your application can use that token to interact with the chatbot: send it messages or status information,
and eventually terminate the conversation.

The callback you give to the conversation is anything that responds to `#call` (e.g. a proc, a method object,
or a custom object that implements the `#call` message). `#call` takes two parameters, the chatbot instance
and the incoming message `String`. Your application is responsible for determining how to respond to that new
message. Here is an example that sends the chatbot a status message, processes the incoming message using
`langchainrb` and `ruby-openai`, and finally sends a final response.

```ruby
Phlex::Chatbot::BotConversation.create(
  user.email,
  lambda do |bot, incoming_message|
    bot.send_status!(message: "I got your message, just a sec...")

    llm  = Langchain::LLM::OpenAI.new(api_key: ENV["OPENAI_API_KEY"])
    chat = llm.chat(messages: [{ role: user.type, content: incoming_message }])

    bot.send_response!(message: chat.chat_completion)
  end,
)
```

This example uses a custom class and the excellent [Sequel](https://sequel.jeremyevans.net/) library to do a
full text search for the top 10 results matching the incoming message.

```ruby
class FullTextSearch
  def self.call(bot, incoming_message)
    bot.send_status!(message: "Compiling results...")

    terms = parse_terms(incoming_message)
    if terms.empty?
      bot.send_failure!(message: "you need to give me some terms")
    else
      results = DB[:fluberties].full_text_search(:borts, terms, rank: true).limit(10).select_map(:blobbities)
      bot.send_response!(message: results.join(". "))
    end
  end

  def self.parse_terms(incoming_message)
    CSV.parse_line(incoming_message).compact.map(&:strip)
  rescue
    []
  end
end

Phlex::Chatbot::BotConversation.create(user.email, FullTextSearch)
```

You can converse with your chatbot in three ways:
1. `#send_status!` - sends a status message that is displayed at the top of the bot's temporary response
1. `#send_response!` - sends a final message that replace's the bot's temporary response
1. `#send_failure!` - similar to `#send_response!` this will replace the bot's temporary response but allows
   the UI to style the response differently, indicating to the user that something unexpected has occured

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update
the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for
the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

While you are actively developing you'll likely want to watch for asset changes:

    $ npm run watch-all

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hedgeyedev/phlex-chatbot.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
