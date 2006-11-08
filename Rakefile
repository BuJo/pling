require 'rake/clean'
require 'rake/testtask'

CLEAN.include('*.png')
CLOBBER.include('*.pnm')

SRC = FileList['*.pnm']
OBJ = SRC.ext('png')

task :default => OBJ

task :open => OBJ do |t|
  sh "open #{t.prerequisites.join(' ')}" if t.prerequisites.size > 0
end

rule '.png' => '.pnm' do |t|
  sh "pnmtopng #{t.source} > #{t.name}"
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/tc_*.rb']
  t.verbose = true
end
