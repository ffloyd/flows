class BenchmarkCLI
  module Examples
    module TenSteps
      class FlowsRailway < Flows::Railway
        step :s1
        step :s2
        step :s3
        step :s4
        step :s5
        step :s6
        step :s7
        step :s8
        step :s9
        step :s10

        def s1(**)
          ok(s1: true)
        end

        def s2(s1:)
          ok(s2: true)
        end

        def s3(s2:)
          ok(s3: true)
        end

        def s4(s3:)
          ok(s4: true)
        end

        def s5(s4:)
          ok(s5: true)
        end

        def s6(s5:)
          ok(s6: true)
        end

        def s7(s6:)
          ok(s7: true)
        end

        def s8(s7:)
          ok(s8: true)
        end

        def s9(s8:)
          ok(s9: true)
        end

        def s10(s9:)
          ok(s10: true)
        end
      end
    end
  end
end
