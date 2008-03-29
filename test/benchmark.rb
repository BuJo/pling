require 'benchmark'
require 'pling'

include Pling

ppm = PPM.new(:mode => :binary) do |a|
  a.width = 100
  a.height = 100
  a.max_color = 255
  a.allocate_data
  a.out = ""
end

r = Renderer.new(ppm)

circle = Circle.new(Quaternion[50,55],40)
circle.color = [200,100,20]

poly1 = Polygon.new
poly1.color = [0,100,255]
poly1.points << Quaternion[0,3] << Quaternion[2,80] << Quaternion[70,60] << Quaternion[40,3]
poly1.edges = [[0,1], [1,2], [2, 3], [3, 0]]

poly2 = Polygon.new
poly2.color = [0,100,255]
poly2.points << Quaternion[0,3] << Quaternion[2,80] << Quaternion[70,60] << Quaternion[40,3]

line = Line.new(Quaternion[1,1], Quaternion[80,90], 255,0,255)

n = 200
Benchmark.bm(12) do |x|
  x.report('poly1: ') { r.objects = [poly1]; n.times { r.render_objects } }
	x.report('poly2: ') { r.objects = [poly2]; n.times { r.render_objects } }
end
