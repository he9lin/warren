module Warren
  module Publisher
    def self.publish(event, payload)
      conn = Bunny.new
      conn.start

      channel  = conn.create_channel
      exchange = channel.topic(Warren::DEFAULT_EXCHANGE_NAME, auto_delete: true)
      exchange.publish(payload, routing_key: event)

      conn.close
    end
  end
end
