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
      @renderer = renderer
      #plot_line(p1, p2)
      bresenham_linie(@p1, @p2)
    end
    
    def set_pixel(x,y)
      @renderer.set(x, y, *@color)
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
    
    # y = ax + b
    def plot_line(p, q)
      s = (q.y-p.y) / (q.x-p.x).to_f
      c = (p.y*q.x - q.y*p.x) / (q.x - p.x ).to_f
      
      for x in p.x..q.x do
        y = (s*x + c + 0.5).to_i
        set_pixel(x,y)
      end
    end
    
    #zeichnet Linie   von P nach q
    def bresenham_linie(p, q)
      p = p.dup
      error, delta, schwelle, dx, dy, inc_x, inc_y = 0
      
      dx = q.x - p.x;
      dy = q.y - p.y;
      
      if (dx > 0) then inc_x = 1; else inc_x = -1; end
      if (dy > 0) then inc_y = 1; else inc_y = -1; end
        
      # flach nach oben oder flach nach unten
      if (dy.abs < dx.abs)
        error = -dx.abs
        delta = 2 * dy.abs
        schwelle = 2 * error
        while (p.x != q.x) do
          set_pixel(p.x, p.y)
          p.x += inc_x
          error = error + delta
          if (error >0) then p.y+=inc_y; error = error + schwelle; end
        end
      # steil nach oben oder steil nach unten
      else
        error = -dy.abs;
        delta = 2*dx.abs;
        schwelle = 2*error;
        while (p.y != q.y) do
          set_pixel(p.x, p.y)
          p.y += inc_y
          error = error + delta
          if (error >0) then p.x+=inc_x; error = error + schwelle; end
        end
      end
      
      set_pixel(q.x, q.y)
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
      @points.each {|x| x.round }
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
      @renderer = renderer
      bresenham_kreis(@m, @r)
    end
    
    def set_pixel(x,y)
      @renderer.set(x, y, *@color)
    end
    
    # zeichnet mit Bresenham-Algorithmus
    def bresenham_kreis(p, r)
      x,y,d,dx,dxy = 0
      y=r
      d=1-r
      dx=3
      dxy = -2*r+5
      
      while (y>=x) do
        set_pixel p.x+x, p.y+y # alle 8 Oktanden werden
        set_pixel p.x+y, p.y+x # gleichzeitig gezeichnet
        set_pixel p.x+y, p.y-x
        set_pixel p.x+x, p.y-y
        set_pixel p.x-x, p.y-y
        set_pixel p.x-y, p.y-x
        set_pixel p.x-y, p.y+x
        set_pixel p.x-x, p.y+y

        if (d<0)
          d=d+dx;  dx=dx+2; dxy=dxy+2
          x += 1
        else
          d=d+dxy; dx=dx+2; dxy=dxy+4
          x += 1
          y -= 1
        end
      end
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