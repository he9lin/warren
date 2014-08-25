module Warren
  module Publisher
    def self.publish(event, payload)
      conn = Bunny.new
      conn.start

      channel  = conn.create_channel
      exchange = channel.topic(Warren::DEFAULT_EXCHANGE_NAME, durable: true)
      exchange.publish(payload, routing_key: event, persistent: true)

      conn.close
    end
  end
end
