require 'test/unit'
require 'pling'

class TestLibraryFileName < Test::Unit::TestCase
  include Pling
  
  def setup
    @ppm = PPM.new(:mode => :ascii) do |a|
      a.width = 4
      a.height = 4
      a.max_color = 15
      a.out = ""
    end
    @ppm.allocate_data
  end

  def test_ppm_magic_value
    assert_equal 'P3', @ppm.magic_value
  end
  
  def test_print
    assert_equal <<-TBL, @ppm.write
P3
# 
4 4
15
0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0
TBL
  end
  
  def test_print
    @ppm.set(3,0, 15, 0,15)
    @ppm.set(1,1,  0,15, 7)
    @ppm.set(2,2,  0,15, 7)
    @ppm.set(0,3, 15, 0,15)
    
    assert_equal <<-TBL, @ppm.write
P3
# 
4 4
15
15 0 15 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 15 7 0 0 0
0 0 0 0 15 7 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 15 0 15
TBL
  end
  
  def test_binary
    ppm = PPM.new(:mode => :binary) do |a|
      a.width = 4
      a.height = 4
      a.allocate_data
      a.max_color = 15
      a.out = ""
    end
    
    ppm.set(3,0, 15, 0,15)
    ppm.set(1,1,  0,15, 7)
    ppm.set(2,2,  0,15, 7)
    ppm.set(0,3, 15, 0,15)
    
    assert_equal <<-TBL.chomp, ppm.write
P6
# 
4 4
15
\017\000\017\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\017\a\000\000\000\000\000\000\000\017\a\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\017\000\017
TBL
  end
  
  def test_pline
    ppm = PPM.new(:mode => :ascii) do |a|
      a.width = 10
      a.height = 10
      a.max_color = 255
      a.allocate_data
      a.out = ""
    end
    
    renderer = Renderer.new(ppm)
    
    line = Line.new(Quaternion[1,1], Quaternion[5,9], 255,0,255)
    
    renderer.objects << line
    renderer.render_objects
    renderer.save('line.pnm')
  end
  
  def test_poly
    ppm = PPM.new(:mode => :ascii) do |a|
      a.width = 10
      a.height = 10
      a.max_color = 255
      a.allocate_data
      a.out = ""
    end
    
    renderer = Renderer.new(ppm)
    
    poly = Polygon.new
    poly.color = [200,100,20]
    poly.points << Quaternion[0,3] << Quaternion[2,9] << Quaternion[7,6] << Quaternion[9,2]
    
    renderer.objects << poly
    renderer.render_objects
    renderer.save('poly.pnm')
  end
  
  def test_poly_transformations
    ppm = PPM.new(:mode => :ascii) do |a|
      a.width = 100
      a.height = 100
      a.max_color = 255
      a.allocate_data
      a.out = ""
    end
    
    renderer = Renderer.new(ppm)
    
    poly = Polygon.new
    poly.color = [0,100,255]
    poly.points << Quaternion[0,3] << Quaternion[2,80] << Quaternion[70,60] << Quaternion[40,3]
    poly.edges = [[0,1], [1,2], [2, 3], [3, 0]]

    line = Line.new(Quaternion[1,1], Quaternion[80,90], 255,0,255)
    
    renderer.objects << [poly.dup, trans(20,50,0)]
    renderer.objects << [poly.dup, scale(0.6, 0.6, 0)]
    renderer.objects << [poly.dup, rotz(-20)]
    
    renderer.render_objects
    renderer.save('poly_translated.pnm')
  end
  
  def test_circle
    ppm = PPM.new(:mode => :ascii) do |a|
      a.width = 10
      a.height = 10
      a.max_color = 255
      a.allocate_data
      a.out = ""
    end
    
    renderer = Renderer.new(ppm)
    
    circle = Circle.new(Quaternion[4,4],4)
    circle.color = [200,100,20]
    
    renderer.objects << circle
    renderer.render_objects
    renderer.save('circle.pnm')
  end
  
  def test_renderer
    fb = Struct.new('FB', :set)
    assert_raises(RuntimeError) do
      Renderer.new(fb)
    end
    assert_raises(RuntimeError) do
      Renderer.new("asdf")
    end
    assert_nothing_raised do
      Renderer.new(PPM.new)
    end
  end
  
end
