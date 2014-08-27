# Warren

A DSL wrapper around bunny to run distributed and communicating apps.

## Installation

Add this line to your application's Gemfile:

    gem 'warren'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install warren

## Usage

Sample usage

```ruby
class DataAnalysisReporter < Warren::Base
  listen 'tarofy.data_analysis.*' do |*args|
    # Update DataAnalysisRunner
  end
end

DataAnalysisReporter.new.start

class UnifiedEventLogger < Warren::Base
  listen 'tarofy.data_analysis.*' do |*args|
    trigger 'tarofy.data_analysis.aggregate.start'
    Hakoy.call(payload)
    trigger 'tarofy.data_analysis.aggregate.end'
  end
end

class TaroStatsRunner < Warren::Base
  config do
    require 'taro_stats'

    TaroStats.configure
  end

  set(:behavior_analyzer) { TaroStats::Analyzer[:behavior] }

  helper do
    def run_behavior_analyzer(payload)
      TaroStats::CommandRunner.run(behavior_analyzer, payload)
    end
  end

  listen 'tarofy.data_analysis.aggregate.complete' do |*args|
    behavior_analyzer.on_start { trigger 'tarofy.data_analysis.behavior.start' }
    behavior_analyzer.on_success { trigger 'tarofy.data_analysis.behavior.success' }
    behavior_analyzer.on_error { trigger 'tarofy.data_analysis.behavior.error' }
    run_behavior_analyzer
  end
end
```
## TODO

* Add connection error handling

## Contributing

1. Fork it ( https://github.com/he9lin/warren/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
