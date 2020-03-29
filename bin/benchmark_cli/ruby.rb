require_relative 'ruby/structs'
require_relative 'ruby/method_exec'

require_relative 'ruby/command'

class BenchmarkCLI
  module Ruby
    BENCHMARKS = {
      structs: Structs,
      method_exec: MethodExec
    }.freeze
  end
end
