module Support
  # Helpers for RSpec
  module Helpers
    def proc_double(result)
      ->(*) { result }.tap do |proc_obj|
        allow(proc_obj).to receive(:call).and_call_original
        allow(proc_obj).to receive(:===).and_call_original
      end
    end

    def make_proc_double(&block)
      allow(block).to receive(:call).and_call_original
      allow(block).to receive(:===).and_call_original
      block
    end
  end
end
