class Physeng
  class Simulation
    class Joint
      attr_reader :fix1, :fix2, :length

      def initialize(fix1, fix2)
        @fix1 = fix1
        @fix2 = fix2
        @length = Math.sqrt((fix1.x - fix2.x)**2 + (fix1.y - fix2.y)**2)
      end
    end
  end
end
