module Warren
  module Publisher
    def self.publish(event, payload)
      conn = Bunny.new
      conn.start

      channel = conn.create_channel
      queue   = channel.queue(event, durable: true)

      queue.publish(payload, persistent: true)

      conn.close
    end
  end
end
