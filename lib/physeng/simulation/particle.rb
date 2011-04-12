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
        if @x <= 0
          @x = 0
          if @xvel < 0
            @xvel = -@xvel
          end
        end
        if @x >= 1
          @x = 1
          if @xvel > 0
            @xvel = -@xvel
          end
        end
        if @y <= 0
          @y = 0
          if @yvel < 0
            @yvel = -@yvel
          end
        end
        if @y >= 1
          @y = 1
          if @yvel > 0
            @yvel = -@yvel
          end
        end
      end
    end
  end
end

