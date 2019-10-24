# rubocop:disable all
require 'flows'
require 'dry/transaction'
require 'trailblazer/operation'

#
# Task: a + b = ?
#

class FlowsSummator < Flows::Operation
  step :sum

  ok_shape :sum

  def sum(a:, b:, **)
    ok(sum: a + b)
  end
end

class FlowsRailwaySummator < Flows::Railway
  step :sum

  def sum(a:, b:)
    ok(sum: a + b)
  end
end

class POROSummator
  def self.call(a:, b:)
    a + b
  end
end

class DrySummator
  include Dry::Transaction

  step :sum

  private

  def sum(a:, b:)
    Success(a + b)
  end
end

class TBSummator < Trailblazer::Operation
  step :sum

  def sum(opts, a:, b:, **)
    opts[:sum] = a + b
  end
end

#
# Task: 10 steps which returns simple value
#

class FlowsTenSteps < Flows::Operation

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

  ok_shape :data

  def s1(**); ok(s1: true); end
  def s2(**); ok(s2: true); end
  def s3(**); ok(s3: true); end
  def s4(**); ok(s4: true); end
  def s5(**); ok(s5: true); end
  def s5(**); ok(s5: true); end
  def s6(**); ok(s6: true); end
  def s7(**); ok(s7: true); end
  def s8(**); ok(s8: true); end
  def s9(**); ok(s9: true); end
  def s10(**); ok(data: :ok); end
end

class FlowsRailwayTenSteps < Flows::Railway
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

  def s1(**); ok(s1: true); end
  def s2(s1:); ok(s2: s1); end
  def s3(s2:); ok(s3: s2); end
  def s4(s3:); ok(s4: s3); end
  def s5(s4:); ok(s5: s4); end
  def s6(s5:); ok(s6: s5); end
  def s7(s6:); ok(s7: s6); end
  def s8(s7:); ok(s8: s7); end
  def s9(s8:); ok(s9: s8); end
  def s10(s9:); ok(data: :ok); end
end

class POROTenSteps
  class << self
    def call()
      s1
      s2
      s3
      s4
      s5
      s6
      s7
      s8
      s9
      s10
    end

    def s1; true; end
    def s2; true; end
    def s3; true; end
    def s4; true; end
    def s5; true; end
    def s6; true; end
    def s7; true; end
    def s8; true; end
    def s9; true; end
    def s10; true; end
  end
end

class DryTenSteps
  include Dry::Transaction

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

  private

  def s1; Success(true); end
  def s2; Success(true); end
  def s3; Success(true); end
  def s4; Success(true); end
  def s5; Success(true); end
  def s6; Success(true); end
  def s7; Success(true); end
  def s8; Success(true); end
  def s9; Success(true); end
  def s10; Success(true); end
end

class TBTenSteps < Trailblazer::Operation
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

  def s1(opts, **); opts[:s1] = true; end
  def s2(opts, **); opts[:s2] = true; end
  def s3(opts, **); opts[:s3] = true; end
  def s4(opts, **); opts[:s4] = true; end
  def s5(opts, **); opts[:s5] = true; end
  def s6(opts, **); opts[:s6] = true; end
  def s7(opts, **); opts[:s7] = true; end
  def s8(opts, **); opts[:s8] = true; end
  def s9(opts, **); opts[:s9] = true; end
  def s10(opts, **); opts[:s10] = true; end
end
