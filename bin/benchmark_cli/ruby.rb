require_relative 'ruby/structs'
require_relative 'ruby/method_exec'
require_relative 'ruby/self_class'

require_relative 'ruby/command'

class BenchmarkCLI
  module Ruby
    BENCHMARKS = {
      structs: Structs,
      method_exec: MethodExec,
      self_class: SelfClass
    }.freeze
  end
end
