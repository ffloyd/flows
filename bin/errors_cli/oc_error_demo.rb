module OCErrorDemo
  class WithoutContract
    include Flows::Plugin::OutputContract
  end

  class WithContract
    include Flows::Plugin::OutputContract

    success_with :ok do
      hash_of(
        x: Integer,
        y: Integer
      )
    end

    def call(result)
      result
    end
  end

  class << self
    include Flows::Result::Helpers

    def no_contract
      WithoutContract.new
    end

    def contract_error
      WithContract.new.call(ok(z: 100))
    end

    def status_error
      WithContract.new.call(ok(:unexpeted_status, x: 1, y: 2))
    end

    def result_type_error
      WithContract.new.call(z: 100)
    end
  end
end
