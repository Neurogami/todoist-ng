require 'rake'


begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
require 'version'

task :default => 'spec:run'

Bones {
  name  'todoist-ng'
  authors  'James Britt'
  email  'james.britt@gmail.com'
  url  'http://www.gitorious.com/projects/todoist-ng'
  version  Neurogami::Todoist::Setup::VERSION
#  rubyforge.name  'todoist-ng'


}
# EOF
