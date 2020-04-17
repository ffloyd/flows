module ResultErrorDemo
  class << self
    include Flows::Result::Helpers

    def success_access_error
      ok(some: :data).error
    end

    def failure_access_error
      err(some: :data).unwrap
    end
  end
end
