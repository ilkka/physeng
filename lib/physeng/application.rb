require 'trollop'

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
      end
    end
  end
end
