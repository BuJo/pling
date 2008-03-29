require 'pling/util'

module Pling
  
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
  
  # General Format
  class PNM < Framebuffer
    attr_accessor :magic_value, :comment
    attr_reader :data, :options
    
    def initialize(options = {:mode => :binary})
      @options = options
      @comment = options[:comment] || options[:filename]
      @out = ""
      yield self if block_given?
      allocate_data
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
    
    def set(x, y, *args)
      return if x >= width || y >= height || x < 0 || y < 0
      
      # Translate, bottom left ist 0,0
      y = (height-1) - y
      
      @data[y][x] = *args
    end
    
    def write
      @out = header
      @out << self.send("write_#{options[:mode]}".to_sym)
      
      return @out
    end
    def write_binary
      raise NotImplementedError
    end
    def write_ascii
      raise NotImplementedError
    end
    def allocate_data
      raise NotImplementedError
    end
  end
  
  # Black/White Image
  class PBM < PNM
    MAGIC_VALUES = {
      :ascii => 'P1',
      :binary => 'P4'
    }
    
    def initialize(options = {:mode => :ascii})
      @magic_value = MAGIC_VALUES[options[:mode]]
      super
    end
    
    def write_ascii
      out = ''
      
      for row in (0...height) do
        for col in (0...width) do
          out << @data[row][col].map {|x| x ? '1' : '0' }.join(' ')
          out << ' ' if col < (width - 1)
        end
        out << "\n"
      end
      
      return out
    end
  end
  
  # Greyscale Image
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
    
    def write_ascii
      out = ''
      
      for row in (0...height) do
        for col in (0...width) do
          #out << (@data[row][col] % 0xFF).to_s
          out << @data[row][col].to_s
          out << ' ' if col < (width - 1)
        end
        out << "\n"
      end
      
      return out
    end
    
    def allocate_data
      @data = Array.new(height) { Array.new(width) { 0 } }
    end
  end
  
  # Color Image
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
      return if x >= width || y >= height || x < 0 || y < 0
      raise "wrong color count "+color.inspect if color.size != 3
      
      # Translate, bottom left ist 0,0
      y = (height-1) - y
      
      @data[y][x] = color
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