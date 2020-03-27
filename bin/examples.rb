# rubocop:disable all
require 'flows'
require 'dry/transaction'
require 'trailblazer/operation'

#
# Task: a + b = ?
#

class SCPSummator < Flows::SharedContextPipeline
  step :sum

  def sum(a:, b:, **)
    ok(sum: a + b)
  end
end

class SCPMutSummator < Flows::SharedContextPipeline
  mut_step :sum

  def sum(ctx)
    ctx[:sum] = ctx[:a] + ctx[:b]
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

class SCPTenSteps < Flows::SharedContextPipeline
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

class SCPMutTenSteps < Flows::SharedContextPipeline
  mut_step :s1
  mut_step :s2
  mut_step :s3
  mut_step :s4
  mut_step :s5
  mut_step :s6
  mut_step :s7
  mut_step :s8
  mut_step :s9
  mut_step :s10

  def s1(ctx); ctx[:s1] = true; end
  def s2(ctx); ctx[:s2] = true; end
  def s3(ctx); ctx[:s3] = true; end
  def s4(ctx); ctx[:s4] = true; end
  def s5(ctx); ctx[:s5] = true; end
  def s5(ctx); ctx[:s5] = true; end
  def s6(ctx); ctx[:s6] = true; end
  def s7(ctx); ctx[:s7] = true; end
  def s8(ctx); ctx[:s8] = true; end
  def s9(ctx); ctx[:s9] = true; end
  def s10(ctx); ctx[:data] = :ok; end
end

class DoTenSteps
  include Flows::Result::Helpers
  extend Flows::Result::Do

  do_notation :call
  def call(**)
    x1 = yield(s1)
    x2 = yield(s2)
    x3 = yield(s3)
    x4 = yield(s4)
    x5 = yield(s5)
    x6 = yield(s6)
    x7 = yield(s7)
    x8 = yield(s8)
    x9 = yield(s9)
    x10 = yield(s10)
  end

  private

  def s1; ok_data(data: true); end
  def s2; ok_data(data: true); end
  def s3; ok_data(data: true); end
  def s4; ok_data(data: true); end
  def s5; ok_data(data: true); end
  def s6; ok_data(data: true); end
  def s7; ok_data(data: true); end
  def s8; ok_data(data: true); end
  def s9; ok_data(data: true); end
  def s10; ok_data(data: true); end
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
