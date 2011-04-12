require 'sdl'

class Physeng
  class Simulation
    def initialize
      SDL::init(SDL::INIT_EVERYTHING)
    end

    def run
      @screen = SDL::set_video_mode(400, 400, 8, SDL::SWSURFACE)
      SDL::quit
      return 0
    end
  end
end
