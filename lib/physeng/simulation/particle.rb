class Physeng
  class Simulation
    class Particle
      attr_reader :x, :y, :xvel, :yvel
      def initialize(x, y, xvel, yvel)
        @x = x
        @y = y
        @xvel = xvel
        @yvel = yvel
      end
    end
  end
end

