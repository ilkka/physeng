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
        # collide from screen edges
        if @x <= 0 && @xvel < 0
          @x = 0
          @xvel = -@xvel
        end
        if @x >= 1 && @xvel > 0
          @x = 1
          @xvel = -@xvel
        end
        if @y <= 0 && @yvel < 0
          @y = 0
          @yvel = -@yvel
        end
        if @y >= 1 && @yvel > 0
          @y = 1
          @yvel = -@yvel
        end
      end
    end
  end
end

