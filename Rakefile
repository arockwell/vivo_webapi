require 'rubygems'
require 'rake'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name = "VivoWebApi"
  s.version = "0.1"
  s.author = "Alex Rockwell"
  s.email = "alexhr@ufl.edu"
  s.homepage = "http://vivo.ufl.edu"
  s.summary = "Web api to perform functions in VIVO."
  s.files = FileList["lib/**/*"].to_a
  s.require_path = "lib"
  s.has_rdoc = false
  s.add_runtime_dependency 'sparql-client'
  s.add_runtime_dependency 'mechanize'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
