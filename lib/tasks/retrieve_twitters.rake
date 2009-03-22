namespace :workon do
  desc "Load private messages from Twitter into statuses"
  task :direct => :environment do
    Status.import
  end
end
