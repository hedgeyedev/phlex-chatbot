# frozen_string_literal: true

require "English"
require "websocket/driver"

module Phlex
  module Chatbot
    module Client
      class WebSocket
        def initialize(env, token)
          @token = token
          @client_socket = ActionCable::Connection::WebSocket.new(
            env,
            self,
            ActionCable::Connection::StreamEventLoop.new,
          )
          @client_socket.rack_response
        end

        def on_open
          Chatbot.logger.debug "Connection opened"
        end

        def on_message(message)
          if message == "ping"
            @client_socket.transmit("pong")
            return
          end
          Chatbot.logger.debug "Received message: #{message}"
          BotConversation.converse(@token, message)
        end

        def on_close(reason, code)
          if (reason.nil? || reason.empty?) && $ERROR_INFO.nil?
            reason = "No reason given"
          elsif $ERROR_INFO
            reason = $ERROR_INFO.message
          end

          Chatbot.logger.debug "Connection closed: #{code} - #{reason}"
        end

        def on_error(message)
          Chatbot.logger.error "Error: #{message}"
        end

        def send_event(event, data)
          @client_socket.transmit(JSON.generate(event: event, data: data))
        end
      end
    end
  end
end
