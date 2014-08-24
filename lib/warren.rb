require "warren/version"
require "bunny"

module Warren
  class Base
    class << self
      def listen(name, &block)
        listen_callbacks[name] = block
      end

      def listen_callbacks
        @_listen_callbacks ||= {}
      end
    end

    def initialize
      @conn = Bunny.new
    end

    def start
      @conn.start
      channel = @conn.create_channel
      channel.prefetch(1)

      listen_callbacks.each do |name, cbk|
        queue = channel.queue(name, durable: true)
        queue.subscribe(ack: true, block: true) do |delivery_info, properties, body|
          cbk.call(delivery_info, properties, body)
          channel.ack(delivery_info.delivery_tag)
        end
      end
    end

    def listen_callbacks
      self.class.listen_callbacks
    end

    def stop
      @conn.close
    end
  end
end

require "warren/publisher"
