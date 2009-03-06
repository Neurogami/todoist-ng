# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'version'

task :default => 'spec:run'

PROJ.name = 'todoist-ng'
PROJ.authors = 'James Britt'
PROJ.email = 'james.britt@gmail.com'
PROJ.url = 'none'
PROJ.version = Neurogami::Todoist::Setup::VERSION
PROJ.rubyforge.name = 'todoist-ng'

PROJ.spec.opts << '--color'

# EOF