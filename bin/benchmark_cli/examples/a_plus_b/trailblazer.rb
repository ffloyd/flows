require 'trailblazer/operation'

class BenchmarkCLI
  module Examples
    module APlusB
      class TB < ::Trailblazer::Operation
        step :calculation

        def calculation(opts, a:, b:)
          opts[:sum] = a + b
        end
      end
    end
  end
end
