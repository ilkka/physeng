require 'sdl'

class Physeng
  class Simulation
    require 'physeng/simulation/particle'

    SCREEN_WIDTH = 400
    SCREEN_HEIGHT = 400
    UPDATE_INTERVAL = 30

    def initialize
      SDL::init(SDL::INIT_EVERYTHING)
      @particles = (1..10).inject([]) do |particles,num|
        particles << Physeng::Simulation::Particle.new(rand, rand, rand, rand)
      end
    end

    def run
      @screen = SDL::set_video_mode(SCREEN_WIDTH, SCREEN_HEIGHT, 8, SDL::SWSURFACE)
      @next_update = SDL::get_ticks + UPDATE_INTERVAL
      while @next_update < 10000
        dirty = @particles.inject([]) do |rects,p|
          screenx = p.x * SCREEN_WIDTH
          screeny = p.y * SCREEN_HEIGHT
          @screen.put_pixel(screenx, screeny, @screen.map_rgb(0, 255, 0))
          rects << [screenx, screeny, 1, 1]
        end
        @screen.update_rects *dirty
        SDL::delay time_to_next_update
        @next_update += UPDATE_INTERVAL
      end
      SDL::quit
      return 0
    end

    private

    def time_to_next_update
      now = SDL::get_ticks
      if @next_update <= now
        0
      else
        @next_update - now
      end
    end
  end
end
