module Flows
  module Ext
    # Module to extend Operation and Railway. Adds implicit building feature.
    module ImplicitBuild
      attr_reader :default_build

      def self.extended(mod)
        mod.instance_variable_set(:@default_build, nil)
      end

      def call(**params)
        @default_build ||= new

        default_build.call(**params)
      end
    end
  end
end
