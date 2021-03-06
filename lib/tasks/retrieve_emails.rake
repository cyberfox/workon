require 'net/imap'
require 'pidfile'

namespace :workon do
  desc "Load emails from gmail into the system"
  task :emails => :environment do
    WORKON_USER = 'demo' if !defined? WORKON_USER
    WORKON_PASSWORD = 'demo' if !defined? WORKON_PASSWORD

    PidFile.with_pidfile('retrieve_emails') do
      imap = Net::IMAP.new('imap.gmail.com', 993, true)
      imap.login(WORKON_USER, WORKON_PASSWORD)
      imap.select('INBOX')
      imap.search(["NOT", "DELETED"]).each do |message_id|
        MailProcessor.receive(imap.fetch(message_id, "RFC822")[0].attr["RFC822"])
        imap.store(message_id, "+FLAGS", [:Deleted])
      end
      imap.logout
      imap.disconnect
    end
  end
end
