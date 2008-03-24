require 'util'

module Pling
  
  class Model
    attr_accessor :color
    
    def write(renderer)
      raise NotImplementedError, "write not implemented"
    end
  end
  
  class Line < Model
    attr_accessor :p1, :p2
    
    def initialize(p1, p2, *color)
      @p1, @p2 = p1, p2
      @color = color
    end
    
    def write(renderer)
      renderer.set_color(*@color)
      #renderer.draw_jagged_line(p1, p2)
      renderer.draw_bresenham_line(@p1, @p2)
    end
    
    def length
      Math.sqrt((@p1.x - @p2.x).abs**2 + (@p1.y - @p2.y).abs**2)
    end
    
    def height
      [@p1.y, @p2.y].sort.reverse
    end
    
    def <=>(o)
      length <=> o.length
    end
    
  end
  
  class Polygon < Model
    attr_accessor :points
    attr_accessor :edges
    
    def initialize(*points)
      @points = points
    end
    
    def points
      @points ||= []
    end
    
    def write(renderer)
      lines.each do |line|
        line.write(renderer)
      end
    end
    
    def translate(*tlations)
      tlations.each do |t|
        @points = points.map do |p|
          t * p
        end
      end
      @points.each {|x| x.round! }
    end
    
    def lines
      if edges
        return edges.map do |p1,p2|
          Line.new(points[p1],points[p2], *@color)
        end
      end
      
      points = @points.dup
      points << @points.first.dup if points.first != points.last
      
      lines = []
      
      for i in 0...(points.size-1) do
        lines << Line.new(points[i],points[i+1], *@color)
      end
      
      return lines
    end
  end
  
  class Circle < Model
    attr_accessor :m, :r
    
    def initialize(m,r)
      @m, @r = m, r
    end
    
    def write(renderer)
      renderer.set_color(*@color)
      renderer.draw_bresenham_circle(@m, @r)
    end
    
  end
  
  class Background < Model
    def initialize(*color)
      @color = color
    end
    
    def write(renderer)
      for row in (0...plane.height) do
        for col in (0...plane.width) do
          renderer.set(col, row, *@color)
        end
      end
    end
  end
  
  
end