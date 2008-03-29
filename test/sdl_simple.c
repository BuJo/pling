#include <stdlib.h>
#include <SDL/SDL.h>
#include <SDL/SDL_image.h>
#include <time.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define RUN_GAME_LOOP 2666
#define PIC_FILE "aufgabe.pnm"

char *picfile;

uint
game_loop_timer(uint interval, void* param)
{
    // Create a user event to call the game loop.
    SDL_Event event;
    
    event.type = SDL_USEREVENT;
    event.user.code = RUN_GAME_LOOP;
    event.user.data1 = param;
    event.user.data2 = 0;
    
    SDL_PushEvent(&event);
    
    return interval;
}


/*
    Load Image, write to given screen
*/
void
limg(SDL_Surface* screen)
{
    SDL_Surface* image;
    image = (SDL_Surface*)IMG_Load(picfile);
    if (image == NULL) {
        printf("Can't load image: %s\n", SDL_GetError());
        return;
    }
    SDL_BlitSurface(image, NULL, screen, NULL);
    SDL_FreeSurface(image);
    SDL_UpdateRect(screen, 0, 0, 0, 0);
}

int
main(int argc, char *argv[])
{
    SDL_Surface *screen;
    SDL_Event event;
    int done = 0;
    
    if (argc < 2) exit(1);
    picfile = argv[1];
    
    if (SDL_Init(SDL_INIT_VIDEO) == -1) {
        printf("Can't init SDL:  %s\n", SDL_GetError());
        exit(1);
    }

    screen = SDL_SetVideoMode(640, 480, 16, SDL_HWSURFACE);
    if (screen == NULL) {
        printf("Can't set video mode: %s\n", SDL_GetError());
        exit(1);
    }

    SDL_TimerID timer = NULL;
    //timer = SDL_AddTimer(500, game_loop_timer, screen);

    struct stat buffer;
    int         status;
    int         fildes;
    time_t changed;
    time_t now = 0;

    fildes = open(PIC_FILE, O_RDWR);
    status = fstat(fildes, &buffer);

    changed = buffer.st_mtime;
    
    // load image the first time
    limg(screen);

    struct timespec rqtp;
    rqtp.tv_sec = 0;
    rqtp.tv_nsec = 1000000;
    
    while ((!done) && SDL_WaitEvent(&event)) {
        switch(event.type) {
            case SDL_QUIT:
                done = 1;
                break;
            case SDL_MOUSEBUTTONDOWN:
                // reload image everytime a mousebutton was pressed
                limg(screen);
                break;
            case SDL_USEREVENT:
                // does not work yet
                if (event.user.code == RUN_GAME_LOOP) {
                    printf("fired!\n");
                    status = fstat(fildes, &buffer);
                    changed = buffer.st_mtime;
                    if (now < changed) {
                        printf("fired!\n");
                        limg(event.user.data1);
                        now = time(NULL);
                    }
                }
                break;
            default:
                break;
        }
    }

    SDL_bool success;

    success = SDL_RemoveTimer(timer);
    SDL_Quit();

    return 0;
}
