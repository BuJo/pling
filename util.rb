require 'matrix'
require 'mathn'

class Vector
  attr_accessor :x, :y, :z, :w
  
  def self.[](*array)
    case array.size
    when 4: true
    when 3: array << 1
    when 2: array << 0 << 1
    else raise
    end
    new(:init_elements, array, copy = false)
  end
  
  def ==(o)
    raise TypeError, "Incompatible" unless self.class === o
    case self.size
    when 4: [x/w,y/w,z/w] == [o.x/o.w, o.y/o.w, o.z/o.w]
    when 3: x/w == o.x/o.w && y/w == o.y/o.w
    end
  end
  
  def round
    @elements.map! {|x| x.respond_to?(:round) ? x.round : x }
  end
  
  def x; @elements[0]; end
  def y; @elements[1]; end
  def z; @elements[2]; end
  def w; @elements[3]; end
  
  def x=(n); @elements[0] = n; end
  def y=(n); @elements[1] = n; end
  def z=(n); @elements[2] = n; end
  def w=(n); @elements[3] = n; end
  
  alias_method :length, :r
  
  def dup
    Quaternion.elements(@elements, true)
  end
  
  def clone
    Quaternion.elements(@elements, true)
  end
  
end
Quaternion = Vector

module Pling
  def rotx(a)
    a = deg_to_rad(a)
    Matrix[
      [1, 0, 0, 0],
      [0, Math.cos(a), Math.sin(a), 0],
      [0, -Math.sin(a), Math.cos(a), 0],
      [0, 0, 0, 1]
    ].transpose
  end
  
  def roty(a)
    a = deg_to_rad(a)
    Matrix[
      [Math.cos(a), 0, -Math.sin(a), 0],
      [0, 0, 1, 0],
      [Math.sin(a), 0, Math.cos(a), 0],
      [0, 0, 0, 1]
    ].transpose
  end
  
  def rotz(a)
    a = deg_to_rad(a)
    Matrix[
      [Math.cos(a), Math.sin(a), 0, 0],
      [-Math.sin(a), Math.cos(a), 0, 0],
      [0, 0, 1, 0],
      [0, 0, 0, 1]
    ].transpose
  end
  
  def trans(x, y, z)
    Matrix[
      [1, 0, 0, 0],
      [0, 1, 0, 0],
      [0, 0, 1, 0],
      [x, y, z, 1],
    ].transpose
  end
  
  def scale(x, y, z, p = nil)
    s = Matrix[
      [x, 0, 0, 0],
      [0, y, 0, 0],
      [0, 0, z, 0],
      [0, 0, 0, 1],
    ]
    p ? trans(-p.x, -p.y, -p.z) * s * trans(-p.x, -p.y, -p.z) : s
  end
  
  def deg_to_rad(g)
    g * (Math::PI/180.0)
  end
end
