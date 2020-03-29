class BenchmarkCLI
  module Helpers
    def header(text)
      width = text.size + 4

      puts '#' * width
      puts "# #{text} #"
      puts '#' * width
      puts
    end
  end
end
