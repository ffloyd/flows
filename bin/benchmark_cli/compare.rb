require_relative 'compare/base'
require_relative 'compare/a_plus_b'
require_relative 'compare/ten_steps'

require_relative 'compare/command'

class BenchmarkCLI
  module Compare
    BENCHMARKS = {
      APlusB::NAME => APlusB,
      TenSteps::NAME => TenSteps
    }.freeze

    MODES = {
      class_call: 'execute `Implementation.call(...)`',
      instance_call: 'execute `instance.call(...)`'
    }.freeze

    IMPLEMENTATIONS = {
      flows_do: {
        title: 'Flows Do-notation',
        modes: [:instance_call],
        classes: {
          APlusB::NAME => Examples::APlusB::FlowsDo,
          TenSteps::NAME => Examples::TenSteps::FlowsDo
        }
      },
      flows_railway: {
        title: 'Flows Railway',
        modes: %i[class_call instance_call],
        classes: {
          APlusB::NAME => Examples::APlusB::FlowsRailway,
          TenSteps::NAME => Examples::TenSteps::FlowsRailway
        }
      },
      flows_scp: {
        title: 'Flows Shared Context Pipeline, functional steps',
        modes: %i[class_call instance_call],
        classes: {
          APlusB::NAME => Examples::APlusB::FlowsSCP,
          TenSteps::NAME => Examples::TenSteps::FlowsSCP
        }
      },
      flows_scp_mut: {
        title: 'Flows Shared Context Pipeline, mutation steps',
        modes: %i[class_call instance_call],
        classes: {
          APlusB::NAME => Examples::APlusB::FlowsSCPMut,
          TenSteps::NAME => Examples::TenSteps::FlowsSCPMut
        }
      },
      dry_do: {
        title: 'dry-rb Do-notation',
        modes: [:instance_call],
        classes: {
          APlusB::NAME => Examples::APlusB::DryDo,
          TenSteps::NAME => Examples::TenSteps::DryDo
        }
      },
      dry_transaction: {
        title: 'dry-rb Transaction',
        modes: [:instance_call],
        classes: {
          APlusB::NAME => Examples::APlusB::DryTransaction,
          TenSteps::NAME => Examples::TenSteps::DryTransaction
        }
      },
      trailblazer: {
        title: 'Trailblazer Operation',
        modes: [:class_call],
        classes: {
          APlusB::NAME => Examples::APlusB::TB,
          TenSteps::NAME => Examples::TenSteps::TB
        }
      }
    }.freeze
  end
end
