rails_template_root = File.dirname(rails_template) + '/rails_root'

# execute rvm
run "rvm use 1.9.2 --rvmrc"

# remove files
run "rm README"
run "rm public/index.html"
run "rm public/images/rails.png"
run "cp config/database.yml config/database.yml.example"

# install gems
run "rm Gemfile"
file 'Gemfile', File.read("#{rails_template_root}/Gemfile")

# bundle install
run "bundle install"

# create sass directory
empty_directory 'public/stylesheets/sass'

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

#change mock testing to use RR
rspec_helper = 'spec/spec_helper.rb'
gsub_file rspec_helper, /#\s*(config.mock_with :rr)/, '\1'
gsub_file rspec_helper, /(config.mock_with :rspec)/, '#\1'

#generate cucumber
generate "cucumber:install --capybara --rspec"
# copy cucumber files
feature_support_dir = 'features/support'
template_path = [rails_template_root , '/', feature_support_dir].join('/')
['factory_girl.rb'].each do |filename|
  copy_file "#{template_path}/#{filename}", "#{feature_support_dir}/#{filename}"
end

#generate pickle
generate "pickle --path --email"

#generate simple form files
generate "simple_form:install"

#generate coffeescript files
generate "barista:install"
empty_directory 'app/coffeescripts'
# add app/coffescripts directory


#copy guardfile
copy_file "#{rails_template_root}/Guardfile", "Guardfile"


# Update application controller with store location functionality.
inject_into_file 'app/controllers/application_controller.rb' , :after => "protect_from_forgery\n" do
  <<-STORELOCATION
  after_filter :store_location
  helper_methods :go_back_path

  protected

  def go_back_path
    session[:return_to] || root_path
  end

  def store_location
    session[:return_to] = request.fullpath if request.get? and
      controller_name != "user_sessions" and  controller_name != "sessions"
  end

  # set default redirect back if no session is set to root_path
  def redirect_back_or_default(default = root_path)
    redirect_to(session[:return_to] || default)
  end

  STORELOCATION
end

# copy error handing controller
app_controller_path = 'app/controllers'
app_view_path ='app/views/errors/'
filename = 'errors_controller.rb'
filename2 = 'errors.html.haml'
copy_file "#{rails_template_root}/#{app_controller_path}/#{filename}", "#{app_controller_path}/#{filename}"
copy_file "#{rails_template_root}/#{app_view_path}/#{filename2}", "#{app_view_path}/#{filename2}"
inject_into_file "config/routes.rb", "  match '*a', :to => 'errors#routing'\n", :after => "Application.routes.draw do\n"



#copy scaffold controller.rb
scaffold_path = 'lib/templates/rails/scaffold_controller'
filename = 'controller.rb'
copy_file "#{rails_template_root}/#{scaffold_path}/#{filename}", "#{scaffold_path}/#{filename}"

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


git :init
git :add => '.'
git :add => 'tmp/.gitkeep -f'
git :add => 'log/.gitkeep -f'
git :commit => "-a -m 'initial commit'"

