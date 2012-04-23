# required for typing in a password for sudo
default_run_options[:pty] = true

set :stage, "ncbostage-ror1"
set :user, "palexand"
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
#role :app, "ncbo-ror-prod1.stanford.edu"
#role :web, "ncbo-ror-prod1.stanford.edu"
#role :db,  "ncbo-ror-prod1.stanford.edu", :primary => true

# svn export --force --username anonymous --password anonymous_ncbo https://bmir-gforge.stanford.edu/svn/flexviz/tags/$flexrelease/flex $destination/public/flex

# #fix logs
# #we want to store logs in /var/logs/rails
# if [ ! -d /var/log/rails/$bpinstance ];
# then
#  mkdir -p /var/log/rails/$bpinstance
#  chown -R $user:$user /var/log/rails/$bpinstance
# fi
# #update sym link
# rm -Rf $destination/log
# ln -s /var/log/rails/$bpinstance/ $destination/log


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
