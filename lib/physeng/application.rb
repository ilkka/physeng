require 'trollop'
require 'sdl'

class Physeng
  class Application
    class << self
      def run!(*arguments)
        p = Trollop::Parser.new do
        end
        @opts = Trollop::with_standard_exception_handling p do
          o = p.parse arguments
          #raise Trollop::HelpNeeded if arguments.empty?
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
