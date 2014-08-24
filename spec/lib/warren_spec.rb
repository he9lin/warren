require 'spec_helper'

describe Warren, 'intergration specs' do
  let(:payload) { Hash.new }

  it 'listens to a queue' do
    result = nil
    klass  = Class.new(Warren::Base) do
      listen 'warren.data_analysis' do |delivery_info, properties, body|
        result = body
      end
    end
    app = klass.new
    thread1 = Thread.new { app.start }
    thread2 = Thread.new {
      sleep 0.1
      Warren::Publisher.publish('warren.data_analysis', 'hello')
      app.stop
    }
    thread1.join
    thread2.join

    expect(result).to eq('hello')
  end
end
