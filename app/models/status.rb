require 'twitter'

class Status < ActiveRecord::Base
  belongs_to :user
  named_scope :active, :conditions => 'done_at IS NULL'
  named_scope :recent, :conditions => ['done_at IS NULL OR done_at > ?', 2.days.ago.to_s(:db)]

  def done?
    !!done_at
  end

  def self.done_message?(msg)
    msg.gsub(/(^ +)|( +$)/, '') =~ /(?i)^done( |$)/
  end

  def self.import
    twitter = Twitter::Base.new(TWITTER_USER, TWITTER_PASSWORD)
    special_messages = []
    max_twitter_id = Status.maximum(:twitter_id).to_i
    begin
      msgs = (max_twitter_id==0) ? twitter.direct_messages : twitter.direct_messages(:since_id => max_twitter_id)
      could_be_more = (msgs.length == 20)
      msgs.each do |message|
        user = User.find_by_twitter_id(message.sender_id)
        unless Status.find_by_twitter_id(message.id)
          if done_message?(message.text)
            special_messages << message
            user = nil
          end
          Status.create(:user => user, :message => message.text, :twitter_created_at => message.created_at, :twitter_id => message.id)
          user.set_gmail_status(message.text) if user.uses_gmail?
        end
        begin
          twitter.destroy_direct_message(message.id)
        rescue Exception => e
          puts "Destroying direct message (#{message.id}) failed -- #{e}"
        end
      end
    end while could_be_more

    # TODO -- process special messages

    special_messages.sort { |x, y| Time.parse(x.created_at) <=> Time.parse(y.created_at)}
    special_messages.each do |message|
      user = User.find_by_twitter_id(message.sender_id)
      if done_message?(message.text)
        last_status = user.statuses.active.last
        last_status.update_attribute :done_at, message.created_at if last_status
        new_current_status = user.statuses.active.last
        user.set_gmail_status(new_current_status.message) if user.uses_gmail? && new_current_status
      end
    end
  end
end
