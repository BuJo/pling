#!/usr/bin/env ruby
#require 'inline'
require 'tempfile'
require 'matrix'

require 'util'
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
        if o.kind_of?(Array)
          obj = o.shift
          o, translations = obj, o
          
          translations.each do |t|
            o.translate(t)
          end
        end
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
  
  circle2 = Circle.new(Quaternion[40,60],20)
  circle2.color = [100,10,230]
  
  poly = Polygon.new
  poly.color = [0,100,255]
  poly.points << Quaternion[0,3] << Quaternion[2,80] << Quaternion[70,60] << Quaternion[40,3]
  poly.edges = [[0,1], [1,2], [2, 3], [3, 0]]
  
  line = Line.new(Quaternion[1,1], Quaternion[80,90], 255,0,255)
  
  renderer.objects << [poly.dup, trans(20,50,0)] << circle << circle2 << line
  renderer.objects << [poly.dup, scale(0.6, 0.6, 0)]
  renderer.objects << [poly.dup, rotz(-20)]
  
  renderer.render_objects
  puts "Time to Render: #{renderer.ttr} seconds"
  renderer.save('pling.pnm')
  
  ppm = PPM.new(:mode => :binary) do |a|
    a.width = 100
    a.height = 100
    a.max_color = 255
    a.allocate_data
    a.out = ""
  end
  renderer = Renderer.new(ppm)
  poly = Polygon.new(Quaternion[82,82], Quaternion[82,50], Quaternion[50,50])
  poly.color = [60,200,25]
  poly.edges = [[0,1], [1,2], [2, 0]]
  
  renderer.objects << Line.new(Quaternion[0,50], Quaternion[100,50], 255,255,255)
  renderer.objects << Line.new(Quaternion[50,0], Quaternion[50,100], 255,255,255)
  
  tr = trans(-16, 8, 0) * scale(1, 0.5, 1) * rotz(-90)
  
  renderer.objects << poly
  renderer.objects << [poly.dup, trans(-50,-50, 0), tr, trans(50,50, 0)]
  
  renderer.render_objects
  puts "Time to Render: #{renderer.ttr} seconds"
  renderer.save('aufgabe.pnm')
end
