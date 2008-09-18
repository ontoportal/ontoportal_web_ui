
set :application, "BioPortal"
set :repository,  "https://bmir-gforge.stanford.edu/svn/bioportalui/1005"
set :svn_username, "ngriff"
set :svn_password, Proc.new {Capistrano::CLI::password_prompt('SVN Password:')}

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/rails/#{application}"
set :user,"ngriff"
# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

#alpha
#role :app, "ncbo-ror1.stanford.edu"
#role :web, "ncbo-ror1.stanford.edu"
#role :db,  "ncbo-ror1.stanford.edu", :primary => true

#stage
role :app, "ncbo-ror-stage1.stanford.edu"
role :web, "ncbo-ror-stage1.stanford.edu"
role :db,  "ncbo-ror-stage1.stanford.edu", :primary => true


#production
#role :app, "ncbo-ror-prod1.stanford.edu"
#role :web, "ncbo-ror-prod1.stanford.edu"
#role :db,  "ncbo-ror-prod1.stanford.edu", :primary => true