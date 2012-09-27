# >---------------------------------------------------------------------------<
#
#            _____       _ _   __          ___                  _
#           |  __ \     (_) |  \ \        / (_)                | |
#           | |__) |__ _ _| |___\ \  /\  / / _ ______ _ _ __ __| |
#           |  _  // _` | | / __|\ \/  \/ / | |_  / _` | '__/ _` |
#           | | \ \ (_| | | \__ \ \  /\  /  | |/ / (_| | | | (_| |
#           |_|  \_\__,_|_|_|___/  \/  \/   |_/___\__,_|_|  \__,_|
#
#   This template was generated by rails_apps_composer, a custom version of
#   RailsWizard, the application template builder. For more information, see:
#   https://github.com/RailsApps/rails_apps_composer/
#
# >---------------------------------------------------------------------------<

# >----------------------------[ Initial Setup ]------------------------------<
# execute rvm
run "rvm use ruby-1.9.3-p194@rails32"

gem 'rails3-generators'
gem 'rvm-capistrano'
gem 'capistrano'

@recipes = ["jquery", "haml", "cucumber", "capybara", "compass", "home_page", "guard", "rspec", "sass", "geocode"]

def recipes; @recipes end
def recipe?(name); @recipes.include?(name) end

def say_custom(tag, text); say "\033[1m\033[36m" + tag.to_s.rjust(10) + "\033[0m" + "  #{text}" end
def say_recipe(name); say "\033[1m\033[36m" + "recipe".rjust(10) + "\033[0m" + "  Running #{name} recipe..." end
def say_wizard(text); say_custom(@current_recipe || 'wizard', text) end

def ask_wizard(question)
  ask "\033[1m\033[30m\033[46m" + (@current_recipe || "prompt").rjust(10) + "\033[0m\033[36m" + "  #{question}\033[0m"
end

def yes_wizard?(question)
  answer = ask_wizard(question + " \033[33m(y/n)\033[0m")
  case answer.downcase
    when "yes", "y"
      true
    when "no", "n"
      false
    else
      yes_wizard?(question)
  end
end

def no_wizard?(question); !yes_wizard?(question) end

def multiple_choice(question, choices)
  say_custom('question', question)
  values = {}
  choices.each_with_index do |choice,i|
    values[(i + 1).to_s] = choice[1]
    say_custom (i + 1).to_s + ')', choice[0]
  end
  answer = ask_wizard("Enter your selection:") while !values.keys.include?(answer)
  values[answer]
end

@current_recipe = nil
@configs = {}

@after_blocks = []
def after_bundler(&block); @after_blocks << [@current_recipe, block]; end
@after_everything_blocks = []
def after_everything(&block); @after_everything_blocks << [@current_recipe, block]; end
@before_configs = {}
def before_config(&block); @before_configs[@current_recipe] = block; end


case Rails::VERSION::MAJOR.to_s
when "3"
  case Rails::VERSION::MINOR.to_s
  when "2"
    say_wizard "You are using Rails version #{Rails::VERSION::STRING}."
    @recipes << 'rails 3.2'
  when "1"
    say_wizard "You are using Rails version #{Rails::VERSION::STRING}."
    @recipes << 'rails 3.1'
  when "0"
    say_wizard "You are using Rails version #{Rails::VERSION::STRING}."
    @recipes << 'rails 3.0'
  else
    say_wizard "You are using Rails version #{Rails::VERSION::STRING} which is not supported."
  end
else
  say_wizard "You are using Rails version #{Rails::VERSION::STRING} which is not supported."
end

# show which version of rake is running
# with the added benefit of ensuring that the Gemfile's version of rake is activated
gemfile_rake_ver = run 'bundle exec rake --version', :capture => true, :verbose => false
say_wizard "You are using #{gemfile_rake_ver.strip}"

say_wizard "Checking configuration. Please confirm your preferences."

# >---------------------------[Add Activerecord Squeel support] ------------------------------<

gem 'squeel', ">= 0.8.10"
gem 'therubyracer', '>= 0.8.2'
gem 'thin'

# >---------------------------[Nullify Blank Attributes ] ------------------------------------<
initializer 'active_record_fixes.rb', <<-RUBY
module NullifyBlankAttributes
  def write_attribute(attr_name, value)
    new_value = value.presence
    super(attr_name, new_value)
  end
end
RUBY

# >-------------------------[Form field defaults] -------------------------------------------<
initializer 'form_field_defaults.rb', <<-RUBY
TEXT_FIELD_MIN = 5
TEXT_FIELD_MAX = 100
TEXT_FIELD_RANGE = TEXT_FIELD_MIN..TEXT_FIELD_MAX

TEXT_AREA_MIN = 5
TEXT_AREA_MAX = 500
TEXT_AREA_RANGE = TEXT_AREA_MIN..TEXT_AREA_MAX
RUBY


# >---------------------------------[ Recipes ]----------------------------------<


# >--------------------------------[ jQuery ]---------------------------------<

@current_recipe = "jquery"
@before_configs["jquery"].call if @before_configs["jquery"]
say_recipe 'jQuery'

config = {}
config['jquery'] = yes_wizard?("Would you like to use jQuery?") if true && true unless config.key?('jquery')
config['ui'] = yes_wizard?("Would you like to use jQuery UI?") if true && true unless config.key?('ui')
@configs[@current_recipe] = config

# Application template recipe for the rails_apps_composer. Check for a newer version here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/jquery.rb

if config['jquery']
  if recipes.include? 'rails 3.0'
    say_wizard "Replacing Prototype framework with jQuery for Rails 3.0."
    after_bundler do
      say_wizard "jQuery recipe running 'after bundler'"
      # remove the Prototype adapter file
      remove_file 'public/javascripts/rails.js'
      # remove the Prototype files (if they exist)
      remove_file 'public/javascripts/controls.js'
      remove_file 'public/javascripts/dragdrop.js'
      remove_file 'public/javascripts/effects.js'
      remove_file 'public/javascripts/prototype.js'
      # add jQuery files
      inside "public/javascripts" do
        get "https://raw.github.com/rails/jquery-ujs/master/src/rails.js", "rails.js"
        get "http://code.jquery.com/jquery-1.6.min.js", "jquery.js"
        if config['ui']
          get "https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.12/jquery-ui.min.js", "jqueryui.js"
        end
      end
      # adjust the Javascript defaults
      # first uncomment "config.action_view.javascript_expansions"
      gsub_file "config/application.rb", /# config.action_view.javascript_expansions/, "config.action_view.javascript_expansions"
      # then add "jquery rails" if necessary
      gsub_file "config/application.rb", /= \%w\(\)/, "= %w(jquery rails)"
      # finally change to "jquery jqueryui rails" if necessary
      if config['ui']
        gsub_file "config/application.rb", /jquery rails/, "jquery jqueryui rails"
      end
    end
  elsif recipes.include? 'rails 3.2'
    if config['ui']
      inside "app/assets/javascripts" do
        get "https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.12/jquery-ui.min.js", "jqueryui.js"
      end
    else
      say_wizard "jQuery installed by default in Rails 3.1."
    end
  else
    say_wizard "Don't know what to do for Rails version #{Rails::VERSION::STRING}. jQuery recipe skipped."
  end
else
  if config['ui']
    say_wizard "You said you didn't want jQuery. Can't install jQuery UI without jQuery."
  end
  recipes.delete('jquery')
end


# >---------------------------------[ HAML ]----------------------------------<

@current_recipe = "haml"
@before_configs["haml"].call if @before_configs["haml"]
say_recipe 'HAML'

config = {}
config['haml'] = yes_wizard?("Would you like to use Haml instead of ERB?") if true && true unless config.key?('haml')
@configs[@current_recipe] = config

# Application template recipe for the rails_apps_composer. Check for a newer version here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/haml.rb

if config['haml']
  if recipes.include? 'rails 3.0'
    # for Rails 3.0, use only gem versions we know that work
    gem 'haml', '3.1.1'
    gem 'haml-rails', '0.3.4', :group => :development
  else
    # for Rails 3.1+, use optimistic versioning for gems
    gem 'haml', '>= 3.1.2'
    gem 'haml-rails', '>= 0.3.4', :group => :development
  end
else
  recipes.delete('haml')
end


# >-------------------------------[ Cucumber ]--------------------------------<

@current_recipe = "cucumber"
@before_configs["cucumber"].call if @before_configs["cucumber"]
say_recipe 'Cucumber'

config = {}
config['cucumber'] = yes_wizard?("Would you like to use Cucumber for your BDD?") if true && true unless config.key?('cucumber')
@configs[@current_recipe] = config

# Application template recipe for the rails_apps_composer. Check for a newer version here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/cucumber.rb

if config['cucumber']
  if recipes.include? 'rails 3.0'
    # for Rails 3.0, use only gem versions we know that work
    gem 'cucumber-rails', '0.5.1', :group => :test
    gem 'capybara', '1.0.0', :group => :test
    gem 'database_cleaner', '0.6.7', :group => :test
    gem 'launchy', '0.4.0', :group => :test
  else
    # for Rails 3.1+, use optimistic versioning for gems
    gem 'cucumber-rails', '>= 1.0.2', :group => :test
    gem 'capybara', '>= 1.1.1', :group => :test
    gem 'database_cleaner', '>= 0.6.7', :group => :test
    gem 'launchy', '>= 2.0.5', :group => :test
  end
else
  recipes.delete('cucumber')
end

if config['cucumber']
  after_bundler do
    say_wizard "Cucumber recipe running 'after bundler'"
    generate "cucumber:install --capybara#{' --rspec' if recipes.include?('rspec')}#{' -D' if recipes.include?('mongoid')}"
    if recipes.include? 'mongoid'
      gsub_file 'features/support/env.rb', /transaction/, "truncation"
      inject_into_file 'features/support/env.rb', :after => 'begin' do
        "\n  DatabaseCleaner.orm = 'mongoid'"
      end
    end
    #Modification.
    create_file "features/support/factory_girl.rb",<<-RUBY
require 'factory_girl'
Dir.glob(File.join(File.dirname(__FILE__), '../../spec/support/factories/*.rb')).each {|f| require f }
RUBY
  end
end

if config['cucumber']
  if recipes.include? 'devise'
    after_bundler do
      say_wizard "Copying Cucumber scenarios from the rails3-devise-rspec-cucumber examples"
      begin
        # copy all the Cucumber scenario files from the rails3-devise-rspec-cucumber example app
        get 'https://raw.github.com/RailsApps/rails3-devise-rspec-cucumber/master/features/users/sign_in.feature', 'features/users/sign_in.feature'
        get 'https://raw.github.com/RailsApps/rails3-devise-rspec-cucumber/master/features/users/sign_out.feature', 'features/users/sign_out.feature'
        get 'https://raw.github.com/RailsApps/rails3-devise-rspec-cucumber/master/features/users/sign_up.feature', 'features/users/sign_up.feature'
        get 'https://raw.github.com/RailsApps/rails3-devise-rspec-cucumber/master/features/users/user_edit.feature', 'features/users/user_edit.feature'
        get 'https://raw.github.com/RailsApps/rails3-devise-rspec-cucumber/master/features/users/user_show.feature', 'features/users/user_show.feature'
        get 'https://raw.github.com/RailsApps/rails3-devise-rspec-cucumber/master/features/step_definitions/user_steps.rb', 'features/step_definitions/user_steps.rb'
        remove_file 'features/support/paths.rb'
        get 'https://raw.github.com/RailsApps/rails3-devise-rspec-cucumber/master/features/support/paths.rb', 'features/support/paths.rb'
      rescue OpenURI::HTTPError
        say_wizard "Unable to obtain Cucumber example files from the repo"
      end
    end
  end
end


# >-------------------------------[ Capybara ]--------------------------------<

@current_recipe = "capybara"
@before_configs["capybara"].call if @before_configs["capybara"]
say_recipe 'Capybara'


@configs[@current_recipe] = config

gem 'capybara', :group => [:development, :test] unless config['cucumber']

after_bundler do
  create_file "spec/support/capybara.rb", <<-RUBY
require 'capybara/rails'
require 'capybara/rspec'
RUBY

  create_file "spec/requests/home_spec.rb", <<-RUBY
require 'spec_helper'

describe 'visiting the homepage' do
  before do
    visit '/'
  end

  it 'should have a body' do
    page.should have_css('body')
  end
end
RUBY
end


# >--------------------------------[ Compass ]--------------------------------<

@current_recipe = "compass"
@before_configs["compass"].call if @before_configs["compass"]
say_recipe 'Compass'

config = {}
config['compass'] = yes_wizard?("Would you like to use Compass for stylesheets?") if true && true unless config.key?('compass')
@configs[@current_recipe] = config

if config['compass']
  if recipes.include? 'rails 3.2'
    gem 'compass-rails'

    after_bundler do
      remove_file 'app/assets/stylesheets/application.css'
      create_file 'app/assets/stylesheets/application.css.sass' do <<-SASS
@import 'compass/utilities/general/clearfix'
@import 'compass/reset'
@import 'compass/css3/box-shadow'
@import 'compass/css3/text-shadow'
@import 'compass/css3/border-radius'
@import 'compass/css3/images'
@import 'blueprint/grid'
SASS
      end
    end
  else
    gem 'compass', :version => '~> 0.11'

    after_bundler do
      run 'bundle exec compass init rails'
    end
  end
else
  receipes.delete('compass')
end



#------- Create HAML Application.html.haml ---------------------

# Haml version of default application layout
remove_file 'app/views/layouts/application.html.erb'
remove_file 'app/views/layouts/application.html.haml'
# There is Haml code in this script. Changing the indentation is perilous between HAMLs.
create_file 'app/views/layouts/application.html.haml' do <<-HAML
!!! 5
%html
  %head
    %title
      = content_for?(:page_title) ? yield(:page_title) : t(:default_title)
    %meta{:charset => "utf-8"}
    %meta{"http-equiv" => "X-UA-Compatible", :content => "IE=edge,chrome=1"}
    %meta{:name => "viewport", :content => "width=device-width, initial-scale=1, maximum-scale=1"}
    = stylesheet_link_tag :application
    = javascript_include_tag :application
    = csrf_meta_tags
  %body{:class => params[:controller]}
    #container.container
      %header
        - flash.each do |name, msg|
          = content_tag :div, msg, :id => "flash_\#{name}" if msg.is_a?(String)
      #main{:role => "main"}
        = yield
      %footer
HAML
        end


# >-------------------------------[ HomePage ]--------------------------------<

@current_recipe = "home_page"
@before_configs["home_page"].call if @before_configs["home_page"]
say_recipe 'HomePage'


@configs[@current_recipe] = config

# Application template recipe for the rails_apps_composer. Check for a newer version here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/home_page.rb

after_bundler do

  say_wizard "HomePage recipe running 'after bundler'"

  # remove the default home page
  remove_file 'public/index.html'

  # create a home controller and view
  generate(:controller, "home index")

  # set up a simple home page (with placeholder content)
  if recipes.include? 'haml'
    remove_file 'app/views/home/index.html.haml'
    # There is Haml code in this script. Changing the indentation is perilous between HAMLs.
    # We have to use single-quote-style-heredoc to avoid interpolation.
    create_file 'app/views/home/index.html.haml' do
    <<-'HAML'
%h3 Home
HAML
    end
  else
    remove_file 'app/views/home/index.html.erb'
    create_file 'app/views/home/index.html.erb' do
    <<-ERB
<h3>Home</h3>
ERB
    end
  end

  # set routes
  gsub_file 'config/routes.rb', /get \"home\/index\"/, 'root :to => "home#index"'

end

# >---------------------------------[geocode] --------------------------------
@current_recipe = "geocode"
@before_configs["guard"].call if @before_configs["guard"]
say_recipe "geocode"

config = {}
config['geocode'] = yes_wizard?("Use Geocoder?") if true && true unless config.key?('geocode')
@configs[@current_recipe] = config
if config['geocode']
  gem 'geocode'

  after_bundler do
    get 'https://raw.github.com/skamithi/rails3-app-template/master/mock_geocode.rb', 'spec/support/mock_geocode.rb'
  end

else
  recipes.delete 'geocode'
end

# >---------------------------------[ guard ]---------------------------------<

@current_recipe = "guard"
@before_configs["guard"].call if @before_configs["guard"]
say_recipe 'guard'

config = {}
config['guard'] = yes_wizard?("Would you like to use Guard to automate your workflow?") if true && true unless config.key?('guard')
config['livereload'] = yes_wizard?("Would you like to enable the LiveReload guard?") if true && true unless config.key?('livereload')
@configs[@current_recipe] = config

if config['guard']
  gem 'guard', '>= 0.6.2', :group => :development

  gem 'libnotify', :group => :development
  gem 'rb-inotify', :group => :development

  def guards
    @guards ||= []
  end

  def guard(name, version = nil)
    args = []
    if version
      args << version
    end
    args << { :group => :development }
    gem "guard-#{name}", *args
    guards << name
  end

  guard 'bundler', '>= 0.1.3'

  unless recipes.include? 'pow'
    guard 'rails', '>= 0.0.3'
  end

  if config['livereload']
    guard 'livereload', '>= 0.3.0'
  end

  if recipes.include? 'rspec'
    guard 'rspec', '>= 0.4.3'
  end

  if recipes.include? 'cucumber'
    guard 'cucumber', '>= 0.6.1'
  end

  after_bundler do
    run 'bundle exec guard init'
    guards.each do |name|
      run "bundle exec guard init #{name}"
    end
  end

else
  recipes.delete 'guard'
end


# >---------------------------------[ RSpec ]---------------------------------<

@current_recipe = "rspec"
@before_configs["rspec"].call if @before_configs["rspec"]
say_recipe 'RSpec'

config = {}
config['rspec'] = yes_wizard?("Would you like to use RSpec instead of TestUnit?") if true && true unless config.key?('rspec')
config['factory_girl'] = yes_wizard?("Would you like to use factory_girl for test fixtures with RSpec?") if true && true unless config.key?('factory_girl')
@configs[@current_recipe] = config

# Application template recipe for the rails_apps_composer. Check for a newer version here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/rspec.rb

if config['rspec']
  if recipes.include? 'rails 3.0'
    # for Rails 3.0, use only gem versions we know that work
    say_wizard "REMINDER: When creating a Rails app using RSpec..."
    say_wizard "you should add the '-T' flag to 'rails new'"
    gem 'rspec-rails', '2.6.1', :group => [:development, :test]
    if recipes.include? 'mongoid'
      # use the database_cleaner gem to reset the test database
      gem 'database_cleaner', '0.6.7', :group => :test
      # include RSpec matchers from the mongoid-rspec gem
      gem 'mongoid-rspec', '1.4.2', :group => :test
    end
    if config['factory_girl']
      # use the factory_girl gem for test fixtures
      gem 'factory_girl_rails', '1.1.beta1', :group => :test
    end
  else
    # for Rails 3.1+, use optimistic versioning for gems
    gem 'rspec-rails', '>= 2.6.1', :group => [:development, :test]
    if recipes.include? 'mongoid'
      # use the database_cleaner gem to reset the test database
      gem 'database_cleaner', '>= 0.6.7', :group => :test
      # include RSpec matchers from the mongoid-rspec gem
      gem 'mongoid-rspec', '>= 1.4.4', :group => :test
    end
    if config['factory_girl']
      # use the factory_girl gem for test fixtures
      gem 'factory_girl_rails', '>= 1.2.0', :group => :test
    end
  end
  gem 'shoulda-matchers', :group => [:development, :test]
else
  recipes.delete('rspec')
end

# note: there is no need to specify the RSpec generator in the config/application.rb file

if config['rspec']
  after_bundler do
    say_wizard "RSpec recipe running 'after bundler'"
    generate 'rspec:install'

    say_wizard "Removing test folder (not needed for RSpec)"
    run 'rm -rf test/'

    inject_into_file 'config/application.rb', :after => "Rails::Application\n" do <<-RUBY

    # don't generate RSpec tests for views and helpers
    config.generators do |g|
      g.request_specs false
      g.fixture_replacement :factory_girl, :dir => "spec/support/factories"
    end

RUBY
    end

    if recipes.include? 'mongoid'

      # remove ActiveRecord artifacts
      gsub_file 'spec/spec_helper.rb', /config.fixture_path/, '# config.fixture_path'
      gsub_file 'spec/spec_helper.rb', /config.use_transactional_fixtures/, '# config.use_transactional_fixtures'

      # reset your application database to a pristine state during testing
      inject_into_file 'spec/spec_helper.rb', :before => "\nend" do
      <<-RUBY
  \n
  # Clean up the database
  require 'database_cleaner'
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = "mongoid"
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end
RUBY
      end

      # remove either possible occurrence of "require rails/test_unit/railtie"
      gsub_file 'config/application.rb', /require 'rails\/test_unit\/railtie'/, '# require "rails/test_unit/railtie"'
      gsub_file 'config/application.rb', /require "rails\/test_unit\/railtie"/, '# require "rails/test_unit/railtie"'

      # configure RSpec to use matchers from the mongoid-rspec gem
      create_file 'spec/support/mongoid.rb' do
      <<-RUBY
RSpec.configure do |config|
  config.include Mongoid::Matchers
end
RUBY
      end
    end

    if recipes.include? 'devise'
      # add Devise test helpers
      create_file 'spec/support/devise.rb' do
      <<-RUBY
RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
end
RUBY
      end
    end

  end
end


# >---------------------------------[ SASS ]----------------------------------<

@current_recipe = "sass"
@before_configs["sass"].call if @before_configs["sass"]
say_recipe 'SASS'

config = {}
config['sass'] = yes_wizard?("Would you like to use SASS syntax instead of SCSS?") if true && true unless config.key?('sass')
@configs[@current_recipe] = config

if recipes.include? 'rails 3.0'
  gem 'sass', '>= 3.1.6'
end

if config['sass']
  after_bundler do
    create_file 'config/initializers/sass.rb' do <<-RUBY
Rails.application.config.generators.stylesheet_engine = :sass
RUBY
    end
  end
end


# >----------------------------[ Simple form ] ------------------------------<
gem 'simple_form'
after_bundler do
  generate 'simple_form:install'
end

# >-------------------------[Add error controller] -------------------------<
after_bundler do
  inject_into_file "config/routes.rb", "  match '*a', :to => 'errors#routing'\n", :after => "Application.routes.draw do\n"

  create_file 'app/controllers/errors_controller.rb', <<-RUBY
class ErrorsController < ApplicationController
  def routing
  end
end
  RUBY

  create_file 'app/views/errors/routing.html.haml', <<-RUBY
#errors
  %span Page not found!
  = link_to 'Return to the previous page', go_back_path
  RUBY
end


# >-------------------[ Update View Helpers] ---------------------------------<
after_bundler do
  # Update application controller with store location functionality.
  inject_into_file 'app/controllers/application_controller.rb' , :after => "protect_from_forgery\n" do
  <<-STORELOCATION
  after_filter :store_location
  helper_method :go_back_path

  protected

  # Return 404 message if item cannot be found in controller
  # Example: @task = Task.find_by_id(params[:id]) || not_found
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  # use this in link_to statements
  # Example: link_to 'Back', go_back_path
  def go_back_path
    session[:return_to] || root_path
  end

  # executed by the after_filter defined in application_controller
  def store_location
    session[:return_to] = request.fullpath if request.get? and
      controller_name != "user_sessions" and  controller_name != "sessions"
  end

  # set default redirect back if no session is set to root_path
  # Use in controller functions that render views
  def redirect_back_or_default(default = root_path)
    redirect_to(session[:return_to] || default)
  end

  STORELOCATION
  end

  #add app wide view functions to application_helper.rb
  inject_into_file 'app/helpers/application_helper.rb', :after => "module ApplicationHelper\n" do
  <<-VIEWHELPERS
  # Defines a way to perseve the parameters in the previous form in the current form
  # Usage: <%= simple_form_for @select_a_meaning,
  #              :url => url_for(merge_params(:controller => 'words', :action => 'select_a_meaning')) do |f| %>
  def merge_params(p={})
    params.merge(p).delete_if{|k,v| v.blank?}
  end

  #print list of app specific css files
  def app_stylesheets(css_files)
    css_files.map {|cf| stylesheet_link_tag cf, :media => 'all' }.join
  end

  VIEWHELPERS

  end

end

# >------------------[ add pry ] --------------------------------------------<
gem 'pry'
gem 'pry-doc'
after_bundler do
  append_file 'config/environments/development.rb', <<-RUBY
silence_warnings do
  require 'pry'
  IRB = Pry
end
RUBY
end

# >-------------------[ Update gitignore] ------------------------------------<

after_bundler do
  remove_dir "spec/requests"
  append_file '.gitignore', <<-CODE
bin/
.rvm/*
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

end

# keep tmp and log
run "touch tmp/.gitkeep"
run "touch log/.gitkeep"


git :init
git :add => '.'
git :add => 'tmp/.gitkeep -f'
git :add => 'log/.gitkeep -f'
git :commit => "-a -m 'initial commit'"


@current_recipe = nil

# >-----------------------------[ Run Bundler ]-------------------------------<

say_wizard "Running 'bundle install'. This will take a while."
run 'bundle install'
say_wizard "Running 'after bundler' callbacks."
require 'bundler/setup'
@after_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call}

@current_recipe = nil
say_wizard "Running 'after everything' callbacks."
@after_everything_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call}

@current_recipe = nil
say_wizard "Finished running the rails_apps_composer app template."
say_wizard "Your new Rails app is ready."

