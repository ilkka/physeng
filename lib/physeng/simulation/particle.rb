class Physeng
  class Simulation
    class Particle
      attr_accessor :x, :y, :xvel, :yvel, :color, :rest_coff, :mass, :radius
      attr_reader :id

      def initialize(x, y, xvel, yvel, color, rc, mass, radius)
        @@counter ||= 1
        @id = @@counter
        @@counter += 1
        @x = x
        @y = y
        @xvel = xvel
        @yvel = yvel
        @color = color
        @rest_coff = rc
        @mass = mass
        @radius = radius
      end

      def paint(screen)
        screenx = (@x + 1.0)/2.0 * screen.w
        screeny = (@y + 1.0)/2.0 * screen.h
        rez = ((screen.w + screen.h) / 2.0) / 2.0
        screen.draw_filled_circle screenx, screeny, @radius * rez, screen.map_rgb(*@color)
      end

      def move!(time_elapsed)
        if Physeng::Application.opts[:gravity]
          @yvel += Physeng::Simulation::GRAVITY * (time_elapsed / 1000.0)
        end
        @x += @xvel * (time_elapsed / 1000.0)
        @y += @yvel * (time_elapsed / 1000.0)
      end
    end
  end
end

