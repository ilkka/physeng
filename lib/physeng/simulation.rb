require 'sdl'

class Physeng
  class Simulation
    require 'physeng/simulation/particle'

    def initialize
      SDL::init(SDL::INIT_EVERYTHING)
      @particles = (1..10).inject([]) do |particles,num|
        particles << Physeng::Simulation::Particle.new([rand, rand], [rand, rand])
      end
    end

    def run
      @screen = SDL::set_video_mode(400, 400, 8, SDL::SWSURFACE)
      SDL::quit
      return 0
    end
  end
end
