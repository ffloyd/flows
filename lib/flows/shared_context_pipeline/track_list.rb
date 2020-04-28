module Flows
  class SharedContextPipeline
    # @api private
    class TrackList
      attr_reader :current_track

      def initialize
        @tracks = { main: Track.new(:main) }
        @current_track = :main
      end

      def initialize_dup(_other)
        @tracks = @tracks.transform_values(&:dup)
      end

      def switch_track(track_name)
        @tracks[track_name] ||= Track.new(track_name)
        @current_track = track_name
      end

      def add_step(step)
        @tracks[@current_track].add_step(step)
      end

      def first_step_name
        @tracks[:main].first_step_name
      end

      def main_track_empty?
        @tracks[:main].empty?
      end

      def to_node_map(method_source)
        @tracks.reduce({}) do |node_map, (_, track)|
          node_map.merge!(
            track.to_node_map(method_source)
          )
        end
      end

      def to_flow(method_source)
        raise NoStepsError, method_source if main_track_empty?

        Flows::Flow.new(
          start_node: first_step_name,
          node_map: to_node_map(method_source)
        )
      end
    end
  end
end
