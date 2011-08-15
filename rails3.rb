# execute rvm
run "rvm use 1.9.2 --rvmrc"

# remove files
run "rm README"
run "rm public/index.html"
run "rm public/images/rails.png"
run "cp config/database.yml config/database.yml.example"

# install gems
run "rm Gemfile"
file 'Gemfile', File.read("#{File.dirname(rails_template)}/Gemfile")

# bundle install
run "bundle install"


application  <<-GENERATORS
config.generators do |g|
  g.template_engine :haml
  g.test_framework  :rspec, :fixture => true, :views => false
  g.integration_tool :rspec, :fixture => true, :views => true
  g.fixture_replacement :factory_girl, :dir => "spec/support/factories"
  g.stylesheets false
end
GENERATORS

# generate rspec
generate "rspec:install"

#generate cucubmer
generate "cucumber:install --capybara --rspec"

#generate pickle
generate "pickle --path --email"

#generate simple form files
generate "simple_form:install"

#generate coffeescript files
generate "barista:install"
empty_directory 'app/coffeescripts'
# add app/coffescripts directory

# copy cucumber files
#feature_support_dir = '/features/support'
#template_path = File.dirname(rails_template) + feature_support_dir
#['factory_girl.rb'].each do |filename|
#file "#{feature_support_dir}/#{filename}", "#{template_path}/#{filename}"
#end

#file 'script/watchr.rb', File.read("#{File.dirname(rails_template)}/featu")
#file 'lib/tasks/dev.rake', File.read("#{File.dirname(rails_template)}/dev.rake")

# install jquery


gsub_file 'config/application.rb', /(config.action_view.javascript_expansions.*)/,
                                   "config.action_view.javascript_expansions[:defaults] = %w(jquery rails)"

# add time format
#environment 'Time::DATE_FORMATS.merge!(:default => "%Y/%m/%d %I:%M %p", :ymd => "%Y/%m/%d")'

# .gitignore
append_file '.gitignore', <<-CODE
bin/
.rvm*
.metadata
.project
.idea/
show/
db/schema.rb
Gemfile.lock
.bundle
db/*.sqlite3
log/
tmp/
config/database.yml
test/
CODE

# keep tmp and log
run "touch tmp/.gitkeep"
run "touch log/.gitkeep"

# git commit
#git :init
#git :add => '.'
#git :add => 'tmp/.gitkeep -f'
#git :add => 'log/.gitkeep -f'
#git :commit => "-a -m 'initial commit'"

