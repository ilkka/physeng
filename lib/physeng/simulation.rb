require 'sdl'

class Physeng
  class Simulation
    require 'physeng/simulation/particle'

    SCREEN_WIDTH = 400
    SCREEN_HEIGHT = 400
    UPDATE_INTERVAL = 30

    Plane = Struct.new :n_x, :n_y, :dist

    def initialize
      SDL::init(SDL::INIT_EVERYTHING)
      @rng = Random.new(Time.now.to_i)
      @particles = (1..10).inject([]) do |particles,num|
        particles << random_particle
      end
      # normal vectors for our bounding planes (3rd component is
      # distance to origin, meaning center of world)
      @planes = [
        Plane.new(1.0, 0.0, 1.0),
        Plane.new(0.0, -1.0, 1.0),
        Plane.new(-1.0, 0.0, 1.0),
        Plane.new(0.0, 1.0, 1.0)
      ]
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
        # collide from bounding planes
        @planes.each do |a|
          distance = p.x * a.n_x + p.y * a.n_y + a[2]
          if distance < 0 and p.xvel * a.n_x + p.yvel * a.n_y < 0
            # reflect velocity
            p.xvel -= 2 * a.n_x * (p.xvel * a.n_x + p.yvel * a.n_y)
            p.yvel -= 2 * a.n_y * (p.xvel * a.n_x + p.yvel * a.n_y)
          end
        end
      end
    end
  end
end
