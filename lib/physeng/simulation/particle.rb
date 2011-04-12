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

      def move!
        @x += @xvel
        @y += @yvel
      end
    end
  end
end

