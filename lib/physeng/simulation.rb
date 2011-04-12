require 'rubygame'

class Physeng
  class Simulation
    SCREEN_WIDTH = 400
    SCREEN_HEIGHT = 400
    UPDATE_INTERVAL = 30
    GRAVITY = 9.78
    NUM_PARTICLES = 10

    require 'physeng/simulation/particle'

    Plane = Struct.new :n_x, :n_y, :dist

    def initialize
      @rng = Random.new(Time.now.to_i)
      @particles = (1..NUM_PARTICLES).inject([]) do |particles,num|
        particles << random_particle
      end
      # normal vectors for our bounding planes (3rd component is
      # distance to origin, meaning center of world)
      @planes = [
        Plane.new( 1.0,  0.0,  0.8),
        Plane.new( 0.0, -1.0,  0.8),
        Plane.new(-1.0,  0.0,  0.8),
        Plane.new( 0.0,  1.0,  0.8)
      ]
    end

    def run
      @screen = Rubygame::Screen.new [SCREEN_WIDTH, SCREEN_HEIGHT], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
      while Rubygame::Clock.runtime < 10000
        elapsed = wait_till_next_frame
        clear_screen
        paint @particles, elapsed
        collide @particles
        @screen.flip
      end
      return 0
    end

    private

    def wait_till_next_frame
      currtime = Rubygame::Clock.runtime
      elapsed = currtime - (@prevtime ||= Rubygame::Clock.runtime)
      if elapsed < UPDATE_INTERVAL
        Rubygame::Clock.wait UPDATE_INTERVAL - elapsed
        currtime = Rubygame::Clock.runtime
        elapsed = currtime - @prevtime
      end
      @prevtime = currtime
      return elapsed
    end

    def random_particle
      Particle.new(@rng.rand(-1.0..1.0), @rng.rand(-1.0..1.0),         # x, y
                   @rng.rand(-0.8..0.8), @rng.rand(-0.8..0.8),         # xvel, yvel
                   3.times.inject([]) {|l,i| l << @rng.rand(0..255)},  # [r, g, b]
                   @rng.rand(0.3..1.0),
                   @rng.rand(1.0..10.0),
                   @rng.rand(0.05..0.2))
    end

    def clear_screen
      @screen.fill [0, 0, 0]
    end

    def paint(paintables, time_elapsed)
      paintables.each do |p|
        p.paint @screen
        p.move! time_elapsed
      end
    end

    def collide(particles)
      particles.each do |p|
        # collide from other particles
        #particles.reject {|o| o == p}.each do |o|
          #distance = Math.sqrt((o.x - p.x)**2 + (o.y - p.y)**2)
          #if distance < p.radius + o.radius
            ## calculate relative velocity
            #xrel = p.xvel - o.xvel
            #yrel = p.yvel - o.yvel
            ## calculate collision normal
            #xnorm = (o.x - p.x) / distance
            #ynorm = (o.y - p.y) / distance
            ## dot product of relative vel and normal
            #vrel_dot_norm = xrel * xnorm + yrel * ynorm
            ## impulse
            #ximpulse = (1 + p.rest_coff) * xnorm * vrel_dot_norm
            #yimpulse = (1 + p.rest_coff) * ynorm * vrel_dot_norm
            #p.xvel = -ximpulse * (o.mass / (p.mass + o.mass))
            #p.yvel = -yimpulse * (o.mass / (p.mass + o.mass))
            #o.xvel = -ximpulse * (p.mass / (p.mass + o.mass))
            #o.yvel = yimpulse * (p.mass / (p.mass + o.mass))
          #end
        #end
        # collide from bounding planes
        @planes.each do |a|
          distance = p.x * a.n_x + p.y * a.n_y + a[2]
          if distance < 0 and p.xvel * a.n_x + p.yvel * a.n_y < 0
            # reflect velocity
            p.xvel -= (1 + p.rest_coff) * a.n_x * (p.xvel * a.n_x + p.yvel * a.n_y)
            p.yvel -= (1 + p.rest_coff) * a.n_y * (p.xvel * a.n_x + p.yvel * a.n_y)
            p.x += -distance * a.n_x
            p.y += -distance * a.n_y
          end
        end
      end
    end
  end
end
