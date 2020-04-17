module RailwayErrorDemo
  class MyRailway < ::Flows::Railway
  end

  class << self
    def call
      MyRailway.new
    end
  end
end
