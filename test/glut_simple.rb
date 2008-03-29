require "opengl"
require "glut"

# ----------------------------------------------------------------------------  
#  Name: glEnable2D  
#  Desc: Enabled 2D primitive rendering by setting up the appropriate orthographic  
#             perspectives and matrices.  
# ----------------------------------------------------------------------------  
def glEnable2D
  iViewport = Array.new(4)
  
  # Get a copy of the viewport
  viewport = GL::GetIntegerv(GL::VIEWPORT)
  return
  # Save a copy of the projection matrix so that we can restore it  
  # when it's time to do 3D rendering again.  
  GL::MatrixMode( GL::PROJECTION )
  GL::PushMatrix()
  GL::LoadIdentity()
  
  # Set up the orthographic projection  
  GL::Ortho(iViewport[0], iViewport[0]+iViewport[2],
            iViewport[1] + iViewport[3], iViewport[1], -1, 1 )
  GL::MatrixMode( GL::MODELVIEW )
  GL::PushMatrix()
  GL::LoadIdentity()
  
  # Make sure depth testing and lighting are disabled for 2D rendering until  
  # we are finished rendering in 2D  
  GL::PushAttrib( GL::DEPTH_BUFFER_BIT | GL::LIGHTING_BIT )
  GL::Disable( GL::DEPTH_TEST )
  GL::Disable( GL::LIGHTING )
end
  
# ----------------------------------------------------------------------------  
# Name: glDisable2D  
# Desc: Disables 2D rendering and restores the previous matrix and render
#       states before they were modified.  
# ----------------------------------------------------------------------------  
def glDisable2D
  GL::PopAttrib
  GL::MatrixMode( GL::PROJECTION )
  GL::PopMatrix
  GL::MatrixMode( GL::MODELVIEW )
  GL::PopMatrix
end

glEnable2D

__END__

# keycode we match against in the keyboard listener
ESCAPE = 27
$width , $height = 1024, 768

initGL = proc do
  # clear to black
  GL.ClearColor(0.0,0.0,0.0,0.0)

  GL.ClearDepth(1.0)
  GL.DepthFunc(GL::LESS)

  # Enables depth testing with that type
  GL.Enable(GL::DEPTH_TEST)
  
  # Enables smooth color shading
  GL.ShadeModel(GL::SMOOTH)

  # Reset the projection matrix
  GL.MatrixMode(GL::PROJECTION)
  GL.LoadIdentity

  # Calculate the aspect ratio of the Window
  GLU.Perspective(45.0, $width/$height, 0.1, 100.0)

  # Reset the modelview matrix
  GL.MatrixMode(GL::MODELVIEW)
end

display = proc do
    # Clear the screen and the depth buffer
    GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)

    # Reset the view
    GL.LoadIdentity

    # Move to the left 1.5 units and into the screen 6.0 units
    GL.Translate(-1.5, 0.0, -6.0)
        
    # -- Draw a triangle --
    GL.Color(1.0,1.0,1.0)
    # Begin drawing a polygon
    GL.Begin(GL::POLYGON)
      GL.Vertex3f( 0.0, 1.0, 0.0)     # Top vertex
      GL.Vertex3f( 1.0, -1.0, 0.0)    # Bottom right vertex
      GL.Vertex3f(-1.0, -1.0, 0.0)    # Bottom left vertex
    # Done with the polygon
    GL.End

    # Move 3 units to the right
    GL.Translate(3.0, 0.0, 0.0)

    # -- Draw a square (quadrilateral) --
    # Begin drawing a polygon (4 sided)
    GL.Begin(GL::QUADS)
      GL.Vertex3f(-1.0, 1.0, 0.0)       # Top Left vertex
      GL.Vertex3f( 1.0, 1.0, 0.0)       # Top Right vertex
      GL.Vertex3f( 1.0, -1.0, 0.0)      # Bottom Right vertex
      GL.Vertex3f(-1.0, -1.0, 0.0)      # Bottom Left
    GL.End
    GL.Flush
    # Since this is double buffered, swap the buffers.
    # This will display what just got drawn.
    GLUT.SwapBuffers
end

reshape = proc do |w,h|
  h = 1 if h == 0
  $width, $height = w,h
  GL.Viewport(0, 0, $width, $height)
  # Re-initialize the window (same lines from InitGL)
  GL.MatrixMode(GL::PROJECTION)
  GL.LoadIdentity
  GLU.Perspective(45.0, $width/$height, 0.1, 100.0)
  GL.MatrixMode(GL::MODELVIEW)
end

keyboard = proc do |key,x,y|
  case (key)
  when ESCAPE
    exit 0
  when 'f'[0]
    GLUT.ReshapeWindow(640,480)
  end
end




# Initialize glut & open a window
GLUT.Init
GLUT.InitDisplayMode(GLUT::DOUBLE | GLUT::RGB | GLUT::DEPTH)
GLUT.InitWindowSize($width, $height)
GLUT.CreateWindow($0)

# initialize opengl
initGL.call

# add callback functions for some event listeners
GLUT.ReshapeFunc(reshape)
GLUT.DisplayFunc(display)
GLUT.KeyboardFunc(keyboard)
GLUT.FullScreen
# enter the main idle loop
GLUT.MainLoop()

