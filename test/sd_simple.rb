$:.unshift '/Library/Ruby/Gems/1.8/gems/rubysdl-1.3.1/lib'

require 'sdl'

if $0 == __FILE__
  SDL.init(SDL::INIT_VIDEO)
  
  screen = SDL.set_video_mode(640, 480, 16, SDL::HWSURFACE)
  
  img = SDL::Surface.load("aufgabe.pnm")
  
  SDL.blit_surface2(img, 0, screen, 0)
  screen.update_rect(0, 0, 0, 0)
  
  sleep(50)
  
end
