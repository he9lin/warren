module Warren
  module Dsl
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

    def helper(mod=nil, &block)
      helpers << if mod
        mod
      elsif block_given?
        Module.new(&block)
      else
        raise 'Must specify a module or a block'
      end
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
end
