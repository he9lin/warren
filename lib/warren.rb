require "warren/version"
require "bunny"

module Warren
  DEFAULT_EXCHANGE_NAME = 'warren-exchange'

  class Base
    class << self
      def configure(&block)
        configurations << block
      end

      def configurations
        @_configurations ||= []
      end

      def listen(name, &block)
        listen_callbacks[name] = block
      end

      def listen_callbacks
        @_listen_callbacks ||= {}
      end

      def helper(&block)
        helpers << Module.new(&block)
      end

      def helpers
        @_helpers ||= []
      end

      def set(name, &block)
        mod = Module.new
        mod.module_eval do
          define_method name, &block
        end
        helpers << mod
      end
    end

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
          context = Class.new do
            def trigger(event, payload)
              Warren::Publisher.publish(event, payload)
            end
          end
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
