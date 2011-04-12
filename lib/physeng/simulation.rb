require 'sdl'

class Physeng
  class Simulation
    require 'physeng/simulation/particle'

    SCREEN_WIDTH = 400
    SCREEN_HEIGHT = 400
    UPDATE_INTERVAL = 30

    def initialize
      SDL::init(SDL::INIT_EVERYTHING)
      @rng = Random.new(Time.now.to_i)
      @particles = (1..10).inject([]) do |particles,num|
        particles << random_particle
      end
    end

    def run
      @screen = SDL::set_video_mode(SCREEN_WIDTH, SCREEN_HEIGHT, 8, SDL::SWSURFACE)
      @next_update = SDL::get_ticks + UPDATE_INTERVAL
      while @next_update < 10000
        clear_screen
        dirty = paint @particles
        collide @particles
        @screen.flip
        SDL::delay time_to_next_update
        @next_update += UPDATE_INTERVAL
      end
      SDL::quit
      return 0
    end

    private

    def random_particle
      Particle.new(@rng.rand(-1.0..1.0), @rng.rand(-1.0..1.0),         # x, y
                   @rng.rand(-0.03..0.03), @rng.rand(-0.03..0.03),         # xvel, yvel
                   3.times.inject([]) {|l,i| l << @rng.rand(0..255)})  # [r, g, b]
    end

    def time_to_next_update
      now = SDL::get_ticks
      if @next_update <= now
        0
      else
        @next_update - now
      end
    end

    def clear_screen
      @screen.fill_rect 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, @screen.map_rgb(0, 0, 0)
    end

    def paint(paintables)
      paintables.inject([]) do |rects,p|
        dirty = p.paint @screen
        p.move!
        rects << dirty
      end
    end

    def collide(particles)
      particles.each do |p|
        # collide from screen edges
        if p.x <= -1.0
          p.x = -1.0
          if p.xvel < 0
            p.xvel = -p.xvel
          end
        end
        if p.x >= 1.0
          p.x = 1.0
          if p.xvel > 0
            p.xvel = -p.xvel
          end
        end
        if p.y <= -1.0
          p.y = -1.0
          if p.yvel < 0
            p.yvel = -p.yvel
          end
        end
        if p.y >= 1.0
          p.y = 1.0
          if p.yvel > 0
            p.yvel = -p.yvel
          end
        end
      end
    end
  end
end
