require 'pidfile'

namespace :workon do
  desc "Load private messages from Twitter into statuses"
  task :direct => :environment do
    PidFile.with_pidfile('retrieve_twitter') do
      Status.import
    end
  end
end
