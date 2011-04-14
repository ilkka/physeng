require 'sdl'

class Physeng
  class Simulation
    UPDATE_INTERVAL = 30
    GRAVITY = 9.78
    GRAV_CONSTANT = 6.674e-11
    MUTUAL_GRAV_ADJUSTMENT = 1e8

    require 'physeng/simulation/particle'
    require 'physeng/simulation/joint'

    Plane = Struct.new :n_x, :n_y, :dist

    def initialize
      SDL::init(SDL::INIT_EVERYTHING)
      SDL::TTF.init
      @opts = Physeng::Application.opts
      @rng = Random.new(Time.now.to_i)
      @particles = (1..@opts[:particles]).inject([]) do |particles,num|
        particles << random_particle
      end
      @joints = @particles.each_cons(2).inject([]) {|memo,pair|
        memo << Physeng::Simulation::Joint.new(pair[0], pair[1])
      } if @opts[:joints]
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
      @screen = SDL::set_video_mode(@opts[:window_size][0], @opts[:window_size][1], 8, SDL::SWSURFACE)
      while true
        elapsed = wait_till_next_frame
        clear_screen
        @particles.each do |particle|
          particle.paint @screen
          particle.move! elapsed
          apply_forces particle, elapsed
          collide particle
        end
        apply_joints(@joints) if @opts[:joints]
        @screen.flip
        break if @opts[:duration] > 0 && SDL::get_ticks > @opts[:duration] * 1000
      end
      SDL::quit
      return 0
    end

    private

    def wait_till_next_frame
      currtime = SDL::get_ticks
      elapsed = currtime - (@prevtime ||= SDL::get_ticks)
      if elapsed < UPDATE_INTERVAL
        SDL::delay UPDATE_INTERVAL - elapsed
        currtime = SDL::get_ticks
        elapsed = currtime - @prevtime
      end
      @prevtime = currtime
      return elapsed
    end

    def random_particle
      Particle.new(@rng.rand(-1.0..1.0), @rng.rand(-1.0..1.0),         # x, y
                   @rng.rand(-0.8..0.8), @rng.rand(-0.8..0.8),         # xvel, yvel
                   3.times.inject([]) {|l,i| l << @rng.rand(0..255)},  # [r, g, b]
                   @rng.rand(0.3..1.0),                                # coefficient of restitution
                   @rng.rand(1.0..100.0),                              # mass
                   @rng.rand(0.01..0.10))                              # radius
    end

    def clear_screen
      @screen.fill_rect 0, 0, @opts[:window_size][0], @opts[:window_size][1], @screen.map_rgb(0, 0, 0)
    end

    def apply_forces(particle, time_elapsed)
      apply_gravity_down(particle, time_elapsed) if @opts[:gravity]
      apply_gravity_to_origin(particle, time_elapsed) if @opts[:center]
      apply_mutual_gravity(particle, time_elapsed) if @opts[:mutual]
    end

    def apply_gravity_down(particle, time_elapsed)
      particle.yvel += Physeng::Simulation::GRAVITY * (time_elapsed / 1000.0)
    end

    def apply_gravity_to_origin(particle, time_elapsed)
      center_dist = Math.sqrt(particle.x**2 + particle.y**2)
      particle.xvel += -particle.x/center_dist * Physeng::Simulation::GRAVITY * (time_elapsed / 1000.0)
      particle.yvel += -particle.y/center_dist * Physeng::Simulation::GRAVITY * (time_elapsed / 1000.0)
    end

    def apply_mutual_gravity(particle, time_elapsed)
      force = [0, 0]
      @particles.reject {|o| o == particle}.each do |other|
        dist = Math.sqrt((other.x - particle.x)**2 + (other.y - particle.y)**2)
        normal = [
          (other.x - particle.x) / dist,
          (other.y - particle.y) / dist
        ]
        force[0] += normal[0] * GRAV_CONSTANT * (particle.mass * other.mass) / dist**2
        force[1] += normal[1] * GRAV_CONSTANT * (particle.mass * other.mass) / dist**2
      end
      particle.xvel += (force[0]/particle.mass) * (time_elapsed / 1000.0) * MUTUAL_GRAV_ADJUSTMENT
      particle.yvel += (force[1]/particle.mass) * (time_elapsed / 1000.0) * MUTUAL_GRAV_ADJUSTMENT
    end

    def collide(particle)
      # collide from other particles
      @particles.reject {|o| o == particle}.each do |other|
        vec = [other.x - particle.x, other.y - particle.y]
        distance = Math.sqrt(vec[0]**2 + vec[1]**2)
        nor = [vec[0]/distance, vec[1]/distance]
        overlap = distance - (particle.radius + other.radius)
        # collision?
        if overlap < 0
          # move to end overlap
          particle.x += (overlap) * nor[0]
          particle.y += (overlap) * nor[1]
          # relative velocity
          vrel = [
            particle.xvel - other.xvel,
            particle.yvel - other.yvel
          ]
          # use average of the coefficients of restitution
          rcoff = (particle.rest_coff + other.rest_coff) / 2.0
          impulse = [
            ((1 + rcoff) * nor[0] * (vrel[0] * nor[0] + vrel[1] * nor[1])) / (1.0/particle.mass + 1.0/other.mass),
            ((1 + rcoff) * nor[1] * (vrel[0] * nor[0] + vrel[1] * nor[1])) / (1.0/particle.mass + 1.0/other.mass)
          ]
          # change velocities
          particle.xvel -= impulse[0] * 1.0/particle.mass
          particle.yvel -= impulse[1] * 1.0/particle.mass
          other.xvel += impulse[0] * 1.0/other.mass
          other.yvel += impulse[1] * 1.0/other.mass
        end
      end
      if @opts[:edges]
        # collide from bounding planes
        @planes.each do |a|
          distance = particle.x * a.n_x + particle.y * a.n_y + a[2]
          if distance < particle.radius and particle.xvel * a.n_x + particle.yvel * a.n_y < 0
            # reflect velocity
            particle.xvel -= (1 + particle.rest_coff) * a.n_x * (particle.xvel * a.n_x + particle.yvel * a.n_y)
            particle.yvel -= (1 + particle.rest_coff) * a.n_y * (particle.xvel * a.n_x + particle.yvel * a.n_y)
            particle.x += (particle.radius - distance) * a.n_x
            particle.y += (particle.radius - distance) * a.n_y
          end
        end
      end
    end

    def paint_joint(joint)
      screenx1 = (joint.fix1.x + 1.0)/2.0 * @screen.w
      screeny1 = (joint.fix1.y + 1.0)/2.0 * @screen.h
      screenx2 = (joint.fix2.x + 1.0)/2.0 * @screen.w
      screeny2 = (joint.fix2.y + 1.0)/2.0 * @screen.h
      @screen.draw_line screenx1, screeny1, screenx2, screeny2, @screen.map_rgb(20, 220, 80)
    end

    def apply_joints(joints)
      joints.each do |joint|
        vec = [
          joint.fix2.x - joint.fix1.x, joint.fix2.y - joint.fix1.y
        ]
        distance = Math.sqrt(vec[0]**2 + vec[1]**2)
        nor = [vec[0] / distance, vec[1] / distance]
        joint.fix2.x += nor[0] * (joint.length - distance)
        joint.fix2.y += nor[1] * (joint.length - distance)
        paint_joint(joint)
      end
    end
  end
end
