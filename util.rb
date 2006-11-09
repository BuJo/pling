require 'matrix'

module Pling
  
  class Quaternion < Vector
    attr_accessor :x, :y, :z, :w
    
    def self.[](*args)
      case args.size
      when 4: true
      when 3: args[3] = 1
      when 2: args[3] = 1; args[2] = 0
      else raise
      end
      super(*args)
    end
    
    def ==(o)
      case self.size
      when 4: [x/w,y/w,z/w] == [o.x/o.w, o.y/o.w, o.z/o.w]
      when 3: x/w == o.x/o.w && y/w == o.y/o.w
      end
    end
    
    def x; @elements[0]; end
    def y; @elements[1]; end
    def z; @elements[2]; end
    def w; @elements[3]; end
    
    def x=(n); @elements[0] = n; end
    def y=(n); @elements[1] = n; end
    def z=(n); @elements[2] = n; end
    def w=(n); @elements[3] = n; end
      
    def length
      r
    end
    
  end
  
end