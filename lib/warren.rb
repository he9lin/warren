require "warren/version"
require "bunny"

module Warren
  require_relative 'warren/dsl'

  DEFAULT_EXCHANGE_NAME = 'warren-exchange'

  module EventTriggerable
    def trigger(event, payload)
      Warren::Publisher.publish(event, payload)
    end
  end

  class Base
    extend Dsl

    def initialize(opts={})
      @conn = Bunny.new(opts)
    end

    def start
      configurations.each(&:call)

      @conn.start
      channel = @conn.create_channel
      channel.prefetch(1)

      exchange = channel.topic(Warren::DEFAULT_EXCHANGE_NAME, durable: true)

      listen_callbacks.each do |name, cbk|
        channel.queue("", durable: true)
               .bind(exchange, routing_key: name)
               .subscribe(ack: true) do |delivery_info, properties, payload|
          context = Class.new
          context.send :include, EventTriggerable
          context.class_eval { define_method(:call, &cbk) }
          helpers.each { |h| context.send :include, h }

          context.new.call(delivery_info, properties, payload)
          channel.ack(delivery_info.delivery_tag)
        end
      end
    end

    def listen_callbacks
      self.class.listen_callbacks
    end

    def configurations
      self.class.configurations
    end

    def helpers
      self.class.helpers
    end

    def stop
      @conn.close
    end
  end
end

require "warren/publisher"
