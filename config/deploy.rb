set :application, "workon"
set :repository,  "git@github.com:cyberfox/workon.git"
set :scm, "git"
set :branch, "master"
set :deploy_via, :remote_cache
set :use_sudo, false

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/#{application}/app"
set :user, "workon"
set :mongrel_config, "/etc/mongrel_cluster/#{application}.yml"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "workon.cyberfox.com"
role :web, "workon.cyberfox.com"
role :db,  "workon.cyberfox.com", :primary => true

task :after_update_code do
  run "cp ~/config/database.yml.production #{release_path}/config/database.yml"
  run "cp ~/config/credentials.rb #{release_path}/config/initializers/credentials.rb"
  run "cd #{release_path}; RAILS_ENV=production rake gems:build"
end

namespace :deploy do
  task :restart do
    run "mongrel_rails cluster::restart -C #{mongrel_config}"
  end
end
