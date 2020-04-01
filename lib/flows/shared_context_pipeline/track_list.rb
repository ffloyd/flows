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

      def add_step(name:, lambda:, router_def:)
        @tracks[@current_track].add_step(name: name, lambda: lambda, router_def: router_def)
      end

      def add_mutation_step(name:, lambda:, router_def:)
        @tracks[@current_track].add_mutation_step(name: name, lambda: lambda, router_def: router_def)
      end

      def first_step_name
        @tracks[:main].first_step_name
      end

      def to_node_map(method_source)
        @tracks.reduce({}) do |node_map, (_, track)|
          node_map.merge!(
            track.to_node_map(method_source)
          )
        end
      end
    end
  end
end
