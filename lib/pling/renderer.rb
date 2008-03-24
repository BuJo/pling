module Pling
  
  # Class Renderer
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
    
    def set_color(*color)
      @color = color
    end
    
    def set_pixel(x, y)
      @framebuffer.set(x, y, *@color)
    end
    
    def save(fn)
      @framebuffer.save(fn)
    end
    
  end # end class Renderer
  
  
  # Class SimpleRenderer < Renderer
  class SimpleRenderer < Renderer
    
    # y = ax + b
    def draw_jagge_line(p, q)
      s = (q.y-p.y) / (q.x-p.x).to_f
      c = (p.y*q.x - q.y*p.x) / (q.x - p.x ).to_f
      
      for x in p.x..q.x do
        y = (s*x + c + 0.5).to_i
        set_pixel(x,y)
      end
    end
    
    #zeichnet Linie   von P nach q
    def draw_bresenham_line(p, q)
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
    
    # zeichnet mit Bresenham-Algorithmus
    def draw_bresenham_circle(p, r)
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
    
    def fill_polygon(poly, color)
      l = poly.lines.sort_by {}
    end
    
    ########################################################################
    # fuellt mit dem Scan-Line-Algorithmus das Innere eines Polygons
    ########################################################################
    
    
    # fuegt in die Liste eine Kante ein
    #
    # @param edges Beginn der Kantenliste   
    # @param p1 einzufuegende Kante
    # @param p2 einzufuegende Kante
    # @param y_next Behandlung von Sonderfaellen: siehe Prozedur Next_y
    
    def insert_edge(edges, p1, p2, y_next)
      max_y, dy = 0, 0
      x2, dx, max_x = 0.0, 0.0, 0.0

      p2 = p2.dup

      dx = (p2.x - p1.x) / (p2.y - p1.y).to_f
      x2 = p2.x
      
      # Sonderfaelle
      if ((p2.y > p1.y) && (p2.y < y_next))
        p2.y -= 1
        x2 = x2 - dx
      end
      if ((p2.y < p1.y) && (p2.y > y_next))
        p2.y += 1
        x2 = x2 + dx
      end

      dy = p2.y - p1.y
      
      if (dy>0)
        max_y = p2.y
        max_x = x2.to_f
        dy =+ 1
      else
        max_y = p1.y
        max_x = (p1.x).to_f
        dy = 1 - dy
      end
      
      # Hilfsobjekt
      edge1 = edges.dup

      while (edge1.next.y_top >= max_y)
        edge1 = edge1.next
      end

      # einfuegen sortiert nach max_y
      newedge = Edge.new(max_y, max_x, dy, dx, edge1.next)
      edge1.next = newedge
    end
    
    
    # liefert den y-Wert des naechsten Knoten laengs der Grenze
    # 
    # @param k Index des Punktes, dessen y-Koordinate verschieden ist von
    #          points[k].y
    # @param points Liste von Punkten
    # @param n Anzahl der Punkte
    def next_y(k, points, n)
      compare_y, new_y = points[k].y, 0
    
      begin
        k = (k+1) % n
        new_y = points[k].y
      end while (new_y == compare_y)
    
      return new_y
    end
    
    # erzeugt nach y sortierte Kantenliste
    # und liefert den kleinsten y-Wer
    #
    # @param n Anzahl der Punkte
    # @param points Punkteliste
    # @param edges Kantenliste
    
    def edge_sort(n, points, edges)
      bottom_y = 0
      p1 = nil
      
      edge1 = Edge.new

      edges.next = edge1
      edge1.next = nil

      edges.y_top = Integer.MAX_VALUE;
      edge1.y_top = -Integer.MAX_VALUE;

      p1 = points.last
      bottom_y = p1.y

      for k in (k...n)
        if (p1.y != points[k].y)
          insert_edge(edges,p1,points[k],next_y(k,points,n));
        else
          set_dither_line(p1,points[k].x)
        end
        
        if (points[k].y < bottom_y)
          bottom_y = points[k].y
        end
        p1 = points[k];
      end
      
      return bottom_y
    end
    
    # aktualisiert den Zeiger auf die letzte
    # aktive Kante und gibt ihn zurueck
    # wegen Dekrementieren der Scan-Line
    # werden einige Kanten aktiv
    
    def update_List_ptr(scan, l_act_edge)
      while (l_act_edge.next.y_top >= scan)
        l_act_edge=l_act_edge.next
      end
      
      return l_act_edge
    end
    
    # sortiert die aktive Kantenliste
    # Liefert den ggf. modifizierten Zeiger
    # auf die letzte aktive Kante zurueck
    #
    # @param edges Beginn der Kantenliste
    # @param l_act_edge Ende der Kantenliste
    
    def sort_intersections(edges, l_act_edge)
      edge1, edge2, edge3 = nil

      edge2 = edges.next

      begin
        edge1=edges;
        while (edge1.next.x_int < edge2.next.x_int)
          edge1=edge1.next
        end
        # tausche edge1.next und edge2.next
        if (edge1 != edge2)
          edge3           = edge2.next.next
          edge2.next.next = edge1.next
          edge1.next      = edge2.next
          edge2.next      = edge3
          l_act_edge      = edge2 if (edge1.next == l_act_edge)
        else
          edge2 = edge2.next
        end
      end while (edge2 != l_act_edge)

      return l_act_edge
    end
    
    # generiert fuer je zwei Schnittpunkte
    # aus der Kantenliste den Zeichne-Aufruf
    #
    # @param edges Beginn der aktuellen Kantenliste
    # @param l_act_edge Ende der aktuellen Kantenliste
    # @param scan Scanline
    
    def fill(edges, l_act_edge, scan)
      q = Quaternion.new

      begin
        edges = edges.next
        q.x = edges.x_int + 0.5
        q.y = scan
        edges = edges.next
        set_dither_line(q, (edges.x_int + 0.5) )

      end while (edges != l_act_edge)
    end
    
    # aktual. die aktiven Kanten in der Kantenliste
    # Kanten mit delta_y=0 werden entfernt. Der ggf.
    # modifizierte Zeiger auf die letzte aktive Kante
    # wird zurueckgegeben
    #
    # @param edges beginnend bei edges
    # @param l_act_edge und endend bei l_act_edge 
    
    def update_edges(edges, l_act_edge)
      prev_edge = Edge.new

      prev_edge = edges;

      begin
        edges = prev_edge.next
        if (edges.delta_y > 1)
          edges.delta_y -= 1
          edges.x_int = edges.x_int - edges.delta_x
          prev_edge = edges
        else
          prev_edge.next = edges.next
          l_act_edge = prev_edge if (edges == l_act_edge)
          edges = nil        # dispose edges
        end
      end while (prev_edge != l_act_edge)
      
      return l_act_edge
    end
    
    # Fuellt das Innere eines Polygons
    #
    # @param points Points to draw
    
    def scan_line_fill(points)
      l_act_edge = Edge.new
      scan, bottom_y = 0, 0
      num_points = points.size
      
      edges = Edge.new
      
      bottom_y = edge_sort(num_points, Points, edges)

      l_act_edge = edges.next
      
      scan = edges.next.y_top
      while scan >= bottom_y
        l_act_edge = update_List_ptr(scan, l_act_edge)
        l_act_edge = sort_intersections(edges, l_act_edge)
        fill(edges, l_act_edge, scan)
        l_act_edge = update_edges(edges, l_act_edge)
        scan -= 1
      end

      # dispose dummies edges.next und edges */
      edges.next = nil
      edges = nil
    end
    
  end # end class SimpleRenderer < Renderer

end