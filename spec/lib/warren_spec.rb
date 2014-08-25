require 'spec_helper'

describe Warren, 'intergration specs' do
  def run_app_test(klass, &block)
    app = klass.new
    app.start
    block.call
    sleep 0.1
    app.stop
  end

  it 'listens to topic queues' do
    result1 = []
    result2 = []

    klass = Class.new(Warren::Base) do
      listen 'analysis.dataready' do |delivery_info, properties, payload|
        result1 << payload
      end

      listen 'analysis.*' do |delivery_info, properties, payload|
        result2 << payload
      end
    end

    run_app_test(klass) do
      Warren::Publisher.publish('analysis.dataready', 'data')
      Warren::Publisher.publish('analysis.log', 'log')
    end

    expect(result1).to eq(['data'])
    expect(result2).to eq(['data', 'log'])
  end

  it 'has helpers' do
    result = nil

    klass = Class.new(Warren::Base) do
      helper do
        def run_analysis(payload)
          "run #{payload}"
        end
      end

      listen 'analysis.dataready' do |delivery_info, properties, payload|
        result = run_analysis(payload)
      end
    end

    run_app_test(klass) do
      Warren::Publisher.publish('analysis.dataready', 'data')
    end

    expect(result).to eq('run data')
  end

  it 'configures settings' do
    value  = false
    result = nil

    klass = Class.new(Warren::Base) do
      configure do
        value = true
      end

      listen 'analysis.dataready' do |delivery_info, properties, payload|
        result = value
      end
    end

    run_app_test(klass) do
      Warren::Publisher.publish('analysis.dataready', 'data')
    end

    expect(result).to eq(true)
  end

  it 'sets some accessors' do
    result = nil

    klass = Class.new(Warren::Base) do
      set(:analyzer) { 'Behavior' }

      listen 'analysis.dataready' do |delivery_info, properties, payload|
        result = analyzer
      end
    end

    run_app_test(klass) do
      Warren::Publisher.publish('analysis.dataready', 'data')
    end

    expect(result).to eq('Behavior')
  end

  it 'triggers event within listen block' do
    result = nil
    klass = Class.new(Warren::Base) do
      listen 'analysis.dataready' do |delivery_info, properties, payload|
        trigger 'analysis.done', 'done'
      end

      listen 'analysis.done' do |delivery_info, properties, payload|
        result = payload
      end
    end

    run_app_test(klass) do
      Warren::Publisher.publish('analysis.dataready', 'data')
    end

    expect(result).to eq('done')
  end
end
