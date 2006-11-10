require 'rake/clean'
require 'rake/testtask'

CLEAN.include('*.png', '*.o')
CLOBBER.include('*.pnm', 'a.out')

SRC = FileList['*.pnm']
OBJ = SRC.ext('png')

task :default => OBJ

task :open => OBJ do |t|
  sh "open #{t.prerequisites.join(' ')}" if t.prerequisites.size > 0
end

rule '.png' => '.pnm' do |t|
  sh "pnmtopng #{t.source} > #{t.name}"
end

# other

SDLPROG = 'a.out'
SDLSRC = FileList['sdl_simple.c']
SDLOBJ = SDLSRC.ext('o')
SDLOBJ << '/sw/lib/libSDLmain.a'

task :sdl => ['a.out']

CC = "gcc"
CFLAGS = " -g -O2 -Wall -I/sw/include #{`sdl-config --cflags`.chomp} #{`pkg-config cairo --cflags`.chomp} "
LDFLAGS =  " -Wall -L/sw/lib #{`sdl-config --libs`.chomp} #{`pkg-config cairo --libs`.chomp} -lSDL_image-1.2.0 "

rule '.o' => '.c' do |t|
  sh "#{CC} #{CFLAGS} -c -o #{t.name} #{t.source}"
end

desc "Build this extension"
file SDLPROG => SDLOBJ do |f|
  sh "#{CC} #{LDFLAGS} -o #{f.name} #{f.prerequisites}"
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/tc_*.rb']
  t.verbose = true
end
