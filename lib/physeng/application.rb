require 'trollop'
require 'sdl'

class Physeng
  class Application
    class << self
      attr_reader :opts

      def run!(*arguments)
        p = Trollop::Parser.new do
          opt :gravity, "World gravity", :default => false
          opt :duration, "Simulation duration in seconds (0 for infinite)", :default => 10
          opt :center, "Center gravity", :default => false
          opt :window_size, "Window size (WIDTHxHEIGHT)", :default => "400x400"
          opt :particles, "Number of particles", :default => 10
          opt :mutual, "Mutual gravity", :default => false
          opt :edges, "Screen edges", :default => true
        end
        @opts = Trollop::with_standard_exception_handling p do
          o = p.parse arguments
          # validate window size argument
          size_components = o[:window_size].split(/x/, 2)
          if size_components.length != 2 or size_components.any? {|c| c.index(/[^0-9]/) != nil}
            raise Trollop::CommandlineError, "invalid window size #{o[:window_size]}"
          end
          o[:window_size] = [size_components[0].to_i, size_components[1].to_i]
          o
        end
        # check that SDL has been built with SGE
        if not SDL::Surface.instance_methods.include? :drawCircle
          $stderr.puts "rubysdl has been built without SGE, can't run"
          return 1
        end
        return Physeng::Simulation.new.run
      end
    end
  end
end
