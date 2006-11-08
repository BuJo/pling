require 'inline'
require 'tempfile'
require 'matrix'


module Pling
  
  class Quaternion
    attr_accessor :x, :y, :z, :w
    
    def initialize(x,y,z)
      @x, @y, @z = x, y, z
      @w = 1
    end
    
    def length
      (@x**2 + @y**2 + @z**2 + @w**2)**(1/2)
    end

    def self.[](x,y,z=nil)
      Quaternion.new(x,y,z)
    end
    
    def ==(o)
      if z
        [x/w,y/w,z/w] == [o.x/o.w, o.y/o.w, o.z/o.w]
      else
        x/w == o.x/o.w && y/w == o.y/o.w
      end
    end
  end
  
  class Figure
    attr_accessor :color
    
    def write(plane)
      raise NotImplementedError, "write not implemented"
    end
  end
  
  class Line < Figure
    attr_accessor :p1, :p2
    
    def initialize(p1, p2, *color)
      @p1, @p2 = p1, p2
      @color = color
    end
    
    def write(plane)
      @plane = plane
      #plot_line(p1, p2)
      #bresenham_linie_1(@p1, @p2)
      bresenham_linie(@p1, @p2)
    end
    
    def set_pixel(x,y)
      @plane.set(x, y, *@color)
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
    
    def bresenham_linie_1(p, q)
      dx    = q.x - p.x;
      dy    = q.y - p.y;
      e     = 0.0;
      s     = dy / dx;
      
      y = p.y
      e = 0
      for x in p.x..q.x do
        set_pixel(x,y)
        e += s
        if e > 0.5
          y += 1
          e -= 1
        end
      end
      
    end
    
    #zeichnet Linie   von P nach q
    def bresenham_linie(p, q)
      p = p.dup
      error, delta, schwelle, dx, dy, inc_x, inc_y = 0
      
      dx = q.x - p.x;
      dy = q.y - p.y;
      
      if (dx > 0) then inc_x= 1; else inc_x=-1; end
      if (dy > 0) then inc_y= 1; else inc_y=-1; end
        
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
  
  class Polygon < Figure
    attr_accessor :points
    
    def points
      @points ||= []
    end
    
    def write(plane)
      lines.each do |line|
        line.write(plane)
      end
    end
    
    def lines
      points = @points.dup
      points << @points.first.dup if @points.first != @points.last
      
      lines = []
      
      for i in 0...(points.size-1) do
        lines << Line.new(points[i],points[i+1], *@color)
      end
      
      return lines
    end
  end
  
  class Circle < Figure
    attr_accessor :m, :r
    
    def initialize(m,r)
      @m, @r = m, r
    end
    
    def write(plane)
      @plane = plane
      bresenham_kreis(@m, @r)
    end
    
    def set_pixel(x,y)
      @plane.set(x, y, *@color)
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
  
  class Background < Figure
    def initialize(*color)
      @color = color
    end
    
    def write(plane)
      for row in (0...plane.height) do
        for col in (0...plane.width) do
          plane.set(col, row, *@color)
        end
      end
    end
  end
  
  class Renderer
    attr_accessor :framebuffer
    attr_accessor :objects
    attr_reader :ttr
    
    def initialize(fb)
      raise "Buffer must respond to :set" unless fb.respond_to?(:set)
      raise "Buffer must implement #set correctly" unless fb.method(:set).arity == -3
      @framebuffer = fb
    end
    
    def objects
      @objects ||= []
    end
    
    def render_objects
      a = Time.now
      objects.each do |o|
        o.write(@framebuffer)
      end
      @ttr = Time.now - a
    end
    
    def save(fn)
      @framebuffer.save(fn)
    end
    
  end
  
  class Framebuffer
    attr_accessor :width, :height
    attr_accessor :out
    
    def initialize(options = {})
      @options = options
      @comment = options[:filename]
      yield self if block_given?
    end
    
    def save(fn = nil)
      @options[:filename] = fn if fn
      File.open("#{@options[:filename] || 'image.out'}",
                  File::WRONLY|File::TRUNC|File::CREAT) do |f|
        f.write self.write
      end
    end
  end
  
  class PNM < Framebuffer
    attr_accessor :magic_value, :comment
    attr_reader :data, :options
    
    def initialize(options = {:mode => :binary})
      @options = options
      @comment = options[:comment] || options[:filename]
      yield self if block_given?
    end
    
    def header
      out = ''
      out << "#{magic_value}\n"
      out << "# #{comment}\n"
      out << "#{width} #{height}\n"
    end
    
    # returns the data at given point
    
    def get(x,y)
      # Translate, bottom left ist 0,0
      y = (height-1) - y
      
      @data[y][x]
    end
    
  end
  
  class PBM < PNM
    MAGIC_VALUES = {
      :ascii => 'P1',
      :binary => 'P4'
    }
    
    def initialize(options = {:mode => :ascii})
      @magic_value = MAGIC_VALUES[options[:mode]]
      super
    end
  end
  
  class PGM < PNM
    attr_accessor :max_grey
    
    MAGIC_VALUES = {
      :ascii => 'P2',
      :binary => 'P5'
    }
    
    def initialize(options = {:mode => :ascii})
      @magic_value = MAGIC_VALUES[options[:mode]]
      @max_grey = 255
      super
    end
    
    def header
      out = super
      out << "#{max_grey}\n"
    end
    
  end
  
  class PPM < PNM
    attr_accessor :max_color
    
    MAGIC_VALUES = {
      :ascii => 'P3',
      :binary => 'P6'
    }
    
    def initialize(options = {:mode => :ascii})
      @magic_value = MAGIC_VALUES[options[:mode]]
      @max_color = 255
      super
    end
    
    def header
      out = super
      out << "#{max_color}\n"
    end
    
    def allocate_data
      @data = Array.new(height) { Array.new(width) { [0,0,0] } }
    end
    
    def set(x,y,*color)
      raise "too big" if x >= width
      raise "too big" if y >= height
      raise "wrong count"+color.inspect if color.size != 3
      
      # Translate, bottom left ist 0,0
      y = (height-1) - y
      
      @data[y][x] = color
    end
    
    def write
      @out = header
      @out << self.send("write_#{options[:mode]}".to_sym)
      
      return @out
    end
    
    def write_binary
      raise unless max_color <= 255
      out = ''
      
      for row in (0...height) do
        for col in (0...width) do
          out << @data[row][col].pack('CCC')
        end
      end
      
      return out
    end
    
    def write_ascii
      out = ''
      
      for row in (0...height) do
        for col in (0...width) do
          out << @data[row][col].join(' ')
          out << ' ' if col < (width - 1)
        end
        out << "\n"
      end
      
      return out
    end
    
  end
  
end

if $0 == __FILE__
  ppm = Pling::PPM.new(:mode => :binary) do |a|
    a.width = 100
    a.height = 100
    a.max_color = 255
    a.allocate_data
    a.out = ""
  end
  
  renderer = Pling::Renderer.new(ppm)
  
  circle = Pling::Circle.new(Pling::Quaternion[50,55],40)
  circle.color = [200,100,20]
  
  renderer.objects << circle
  renderer.render_objects
  puts "Time to Render: #{renderer.ttr} seconds"
  renderer.save('pling.pnm')
end
