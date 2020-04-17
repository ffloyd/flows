module SCPErrorDemo
  class MySCP < ::Flows::SharedContextPipeline; end

  class NoImplSCP < ::Flows::SharedContextPipeline
    step :hello
  end

  class << self
    def no_steps
      MySCP.new
    end

    def no_step_impl
      NoImplSCP.new
    end
  end
end
