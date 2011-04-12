class Physeng
  class Simulation
    class Particle
      attr_reader :x, :y, :xvel, :yvel, :color

      def initialize(x, y, xvel, yvel, color)
        @x = x
        @y = y
        @xvel = xvel
        @yvel = yvel
        @color = color
      end

      def paint(screen)
        screenx = @x * screen.w
        screeny = @y * screen.h
        screen.draw_filled_circle screenx, screeny, 2, screen.map_rgb(*@color)
        return [screenx-2, screeny-2, 4, 4]
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

