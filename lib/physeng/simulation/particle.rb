class Physeng
  class Simulation
    class Particle
      attr_accessor :x, :y, :xvel, :yvel, :color

      def initialize(x, y, xvel, yvel, color)
        @x = x
        @y = y
        @xvel = xvel
        @yvel = yvel
        @color = color
      end

      def paint(screen)
        screenx = (@x + 1.0)/2.0 * screen.w
        screeny = (@y + 1.0)/2.0 * screen.h
        screen.draw_filled_circle screenx, screeny, 5, screen.map_rgb(*@color)
      end

      def move!(time_elapsed)
        @yvel += Physeng::Simulation::GRAVITY * (time_elapsed / 1000.0)
        @x += @xvel * (time_elapsed / 1000.0)
        @y += @yvel * (time_elapsed / 1000.0)
        if @x < -1.0
          @x = -1.0
        elsif @x > 1.0
          @x = 1.0
        end
        if @y < -1.0
          @y = -1.0
        elsif @y > 1.0
          @y = 1.0
        end
      end
    end
  end
end

