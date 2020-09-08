module InterfaceErrorDemo
  class Parent
    extend Flows::Plugin::Interface

    defmethod :execute
    defmethod :debug
  end

  class Child < Parent
  end

  class << self
    def missing_implementation
      Child.new
    end
  end
end
