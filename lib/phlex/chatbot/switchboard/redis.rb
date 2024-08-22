# frozen_string_literal: true

require "concurrent"
require "concurrent-edge"
require_relative "base"

module Phlex
  module Chatbot
    module Switchboard
      class Redis < Base
        include Singleton

        TEN_MINUTES = 10 * 60 # seconds

        def initialize
          @channels   = Concurrent::Hash.new
          @redis_db   = ENV["REDIS_URL"] ? ::Redis.new(url: ENV["REDIS_URL"]) : ::Redis.new
          @subscriber = RedisSubscriber.spawn(name: :redis_subscriber, args: [@redis_db])
        end

        def create(id)
          extend_ttl(id) || @redis_db.setex(id, TEN_MINUTES, true)
          (channels[id] ||= ChannelWrapper.new(id, Phlex::Chatbot.callback, @subscriber)).channel_id
        end

        def extend_ttl(channel_id)
          @redis_db.getex(channel_id, ex: TEN_MINUTES)
        end

        def find(channel_id)
          unless extend_ttl(channel_id)
            @channels.delete(channel_id)
            return
          end

          channels[channel_id] ||= ChannelWrapper.new(channel_id, Phlex::Chatbot.callback, @subscriber)
        end

        class ChannelWrapper < Channel
          def initialize(channel_id, callback, subscriber)
            super(channel_id, callback)

            @redis_subscriber = subscriber
          end

          def broadcast_event(event, data:)
            send_event(event, data: data, as_broadcast: true)
          end

          protected

          def send_event(event, data:, as_broadcast: false)
            return super(event, data: data) if as_broadcast

            @redis_subscriber.tell([event, @channel_id, data])
          end
        end

        class RedisSubscriber < Concurrent::Actor::RestartingContext
          CHANNEL_NAME = "phlex:chatbot:switchboard:redis"

          def initialize(redis_db)
            @redis_db = redis_db
            Thread.start do
              @redis_db.subscribe(CHANNEL_NAME) do |on|
                on.message do |_, msg|
                  Phlex::Chatbot.logger.debug "Received msg: #{msg}"
                  decoded_msg = JSON.parse(msg, symbolize_names: true)
                  channel_id  = decoded_msg[:channel_id]
                  channel     = Switchboard::Redis.instance.find(channel_id)

                  channel&.broadcast_event(decoded_msg[:event], data: decoded_msg[:data])
                end
              end
            end
          end

          def on_message(message)
            # TODO: replace the case!!
            case message
            in :joined, channel_id, data
              @redis_db.publish(CHANNEL_NAME, { channel_id: channel_id, event: :joined, data: data }.to_json)
            in :resp, channel_id, data
              @redis_db.publish(CHANNEL_NAME, { channel_id: channel_id, event: :resp, data: data }.to_json)
            else
              raise "unsupported message: #{message}"
            end
          rescue StandardError => e
            Phlex::Chatbot.logger.error e
            # pass to ErrorsOnUnknownMessage behaviour, which will just fail
            pass
          end
        end
      end
    end
  end
end
