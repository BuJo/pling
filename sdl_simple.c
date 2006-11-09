#include <stdlib.h>
#include <SDL/SDL.h>

static SDL_Surface *
limg(SDL_Surface *screen)
{
    SDL_Surface *image;
    image = IMG_Load("pling.pnm");
        if (image == NULL) {
            printf("Can't load image of tux: %s\n", SDL_GetError());
            exit(1);
    }
    SDL_BlitSurface(image, NULL, screen, NULL);
    SDL_FreeSurface(image);
    SDL_UpdateRect(screen, 0, 0, 0, 0);
}

int main(int argc, char *argv[])
{
   SDL_Surface *screen, *image;
   SDL_Event event;
   int done = 0;
   if (SDL_Init(SDL_INIT_VIDEO) == -1) {
       printf("Can't init SDL:  %s\n", SDL_GetError());
       exit(1);
   }
   atexit(SDL_Quit); 
   screen = SDL_SetVideoMode(640, 480, 16, SDL_HWSURFACE);
   if (screen == NULL) {
       printf("Can't set video mode: %s\n", SDL_GetError());
       exit(1);
   }
   
   limg(screen);
   
   while (!done) {
       while (SDL_PollEvent(&event)) {
            switch(event.type) {
            case SDL_QUIT:
               done = 1;
               break;
            case SDL_MOUSEBUTTONDOWN:
                limg(screen);
                break;
           }
       }
   }
   return 0;
}