require 'twitter'

class Status < ActiveRecord::Base
  belongs_to :user
  named_scope :active, :conditions => 'done_at IS NULL'

  def done?
    !!done_at
  end

  def self.done_message?(msg)
    msg.gsub(/(^ +)|( +$)/, '') =~ /(?i)^done( |$)/
  end

  def self.import
    twitter = Twitter::Base.new(TWITTER_USER, TWITTER_PASSWORD)
    special_messages = []
    begin
      msgs = twitter.direct_messages
      could_be_more = (msgs.length == 20)
      msgs.each do |message|
        user = User.find_by_twitter_id(message.sender_id)
        if done_message?(message.text)
          special_messages << message
        else
          Status.create(:user => user, :message => message.text, :twitter_created_at => message.created_at)
        end
        twitter.destroy_direct_message(message.id)
      end
    end while could_be_more

    # TODO -- process special messages

    special_messages.sort { |x, y| Time.parse(x.created_at) <=> Time.parse(y.created_at)}
    special_messages.each do |message|
      user = User.find_by_twitter_id(message.sender_id)
      if done_message?(message.text)
        last_status = user.statuses.active.last
        last.update_attribute :done_at, message.created_at if last
      end
    end
  end
end
