class Physeng
  class Simulation
    class Particle
      attr_reader :pos, :vel
      def initialize(pos, vel)
        @pos = pos
        @vel = vel
      end
    end
  end
end

