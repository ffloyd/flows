module DIErrorDemo
  class WithDI
    include Flows::Plugin::DependencyInjector

    dependency :req_str_dep, required: true, type: String

    def call
      'Hi!'
    end
  end

  class WithEmptyDI
    include Flows::Plugin::DependencyInjector
  end

  class << self
    def missing_dependency
      WithDI.new
    end

    def unexpected_dependency
      WithDI.new(dependencies: {
                   req_str_dep: 'AAA',
                   my_extra_dependency: 'III'
                 })
    end

    def invalid_type_dependency
      WithDI.new(dependencies: {
                   req_str_dep: :AAA
                 })
    end

    def missing_default
      WithEmptyDI.dependency :my_opt_dep
    end
  end
end
