require 'twitter'

class Status < ActiveRecord::Base
  belongs_to :user
  named_scope :active, :conditions => 'done_at IS NULL'

  def done?
    !!done_at
  end

  def self.import
    twitter = Twitter::Base.new(TWITTER_USER, TWITTER_PASSWORD)
    begin
      msgs = twitter.direct_messages
      could_be_more = (msgs.length == 20)
      msgs.each do |message|
        user = User.find_by_twitter_id(message.sender_id)
        Status.create(:user => user, :message => message.text)
        twitter.destroy_direct_message(message.id)
      end
    end while could_be_more
  end
end
