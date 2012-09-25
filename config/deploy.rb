# required for typing in a password for sudo
default_run_options[:pty] = true

set :stage, "stage-hostname"
set :user, "SSHUserOnStage"
set :flex_release, "stage"

set :application, "BioPortal"
set :repository,  "https://bmir-gforge.stanford.edu/svn/bioportalui/trunk"
set :svn_username, "anonymous"
set :svn_password, "anonymous_ncbo"

set :scm, :subversion

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/rails/#{application}"

# stage
server stage, :app, :web, :db, :primary => true

# production
#role :app, "ror-prod1.example.org"
#role :web, "ror-prod1.example.org"
#role :db,  "ror-prod1.example.org", :primary => true

# svn export --force --username anonymous --password anonymous_ncbo https://bmir-gforge.stanford.edu/svn/flexviz/tags/$flexrelease/flex $destination/public/flex

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'airbrake-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'airbrake/capistrano'
