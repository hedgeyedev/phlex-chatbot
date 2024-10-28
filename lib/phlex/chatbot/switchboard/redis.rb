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

        def self.new_redis_connection
          ::Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
        end

        def initialize
          @channels   = Concurrent::Hash.new
          @redis_db   = self.class.new_redis_connection
          @subscriber = RedisSubscriber.spawn(name: :redis_subscriber)
        end

        def create(channel_id)
          extend_ttl(channel_id) || @redis_db.setex(channel_id, TEN_MINUTES, true)
          (channels[channel_id] ||= ChannelWrapper.new(channel_id, @subscriber)).channel_id
        end

        def extend_ttl(channel_id)
          @redis_db.getex(channel_id, ex: TEN_MINUTES)
        end

        def find(channel_id)
          unless extend_ttl(channel_id)
            channels.delete(channel_id)
            return
          end

          channels[channel_id] ||= ChannelWrapper.new(channel_id, @subscriber)
        end

        class ChannelWrapper < Channel
          def initialize(channel_id, subscriber)
            super(channel_id)

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

          def initialize
            @redis_db = Switchboard::Redis.new_redis_connection
            executor = Concurrent::SingleThreadExecutor.new(auto_terminate: true)
            Concurrent::Promises.future_on(executor, @redis_db) do |redis|
              Phlex::Chatbot.logger.info "Starting up Redis subscriber"
              @redis_db.subscribe(CHANNEL_NAME) do |on|
                on.message do |_, msg|
                  Phlex::Chatbot.logger.debug "Received msg: #{msg}"
                  decoded_msg = JSON.parse(msg, symbolize_names: true)
                  channel_id  = decoded_msg[:channel_id]
                  channel     = Switchboard::Redis.instance.find(channel_id)

                  Phlex::Chatbot.logger.warn("Channel not found: #{channel_id}") unless channel
                  channel&.broadcast_event(decoded_msg[:event], data: decoded_msg[:data])
                end
              end
              Phlex::Chatbot.logger.info "Shutting down Redis subscriber"
            end
          end

          def on_message(message)
            # TODO: replace the case!!
            case message
            in :terminate, reason
              terminate(reason)
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
