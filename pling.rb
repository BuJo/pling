#!/usr/bin/env ruby
#require 'inline'
require 'tempfile'
require 'matrix'

require 'model'
require 'framebuffer'

module Pling
  
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
        o.write(self)
      end
      @ttr = Time.now - a
    end
    
    def set(x, y, *colors)
      @framebuffer.set(x, y, *colors)
    end
    
    def save(fn)
      @framebuffer.save(fn)
    end
    
  end
  
end

if $0 == __FILE__
  include Pling
  
  ppm = PPM.new(:mode => :binary) do |a|
    a.width = 100
    a.height = 100
    a.max_color = 255
    a.allocate_data
    a.out = ""
  end
  
  renderer = Renderer.new(ppm)
  
  circle = Circle.new(Quaternion[50,55],40)
  circle.color = [200,100,20]
  
  circle2 = Pling::Circle.new(Pling::Quaternion[40,60],20)
  circle2.color = [100,10,230]
  
  poly = Polygon.new
  poly.color = [0,100,255]
  poly.points << Quaternion[0,3] << Quaternion[2,80] << Quaternion[70,60] << Quaternion[9,2]
  
  renderer.objects << poly << circle << circle2
  
  renderer.render_objects
  puts "Time to Render: #{renderer.ttr} seconds"
  renderer.save('pling.pnm')
end
