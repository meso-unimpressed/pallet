# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'

begin
  require 'rake/rdoctask'
rescue
  require 'rdoc/task'
end

require 'tasks/rails'
