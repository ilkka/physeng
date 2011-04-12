require 'trollop'
require 'rubygame'

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
        Rubygame::init
        return Physeng::Simulation.new.run
      end
    end
  end
end
