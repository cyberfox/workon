require 'digest/sha1'
require 'xmpp4r-simple'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  named_scope :visible, :conditions => { :visible => true }
  has_many :statuses

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  # It's possible to not have an email, if the user creates themself by following the 'workon' user.
#  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100, :if => :email_present? #r@a.wk
  validates_uniqueness_of   :email, :if => :email_present?
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message, :if => :email_present?

  before_create :set_access_key

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :twitter_id, :twitter_name

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  # 3 twitter API methods at once; that's a lot, unfortunately.
  def follow
    twitter = Twitter::Base.new(TWITTER_USER, TWITTER_PASSWORD)
    begin
      twitter.create_friendship(twitter_id)
      twitter.follow(twitter_id)
    rescue Twitter::AlreadyFollowing => following
      logger.warn "Failed to follow #{twitter_id}; we're already following them."
    end
    twitter.d(twitter_id, "http://workon.cyberfox.com/user/#{access_key} to view recent tasks. 'd workon {task}' to add, 'd workon done' to finish. ~2min response time.")
  end

  def uses_gmail?
    email_present && email.include?('@gmail.com') && !gmail_password.nil?
  end

  def set_gmail_status(text)
    jab = Jabber::Simple.new(email, gmail_password)
    jab.status(nil, text)
  end

  protected
  def password_required?
    return false if password.nil? && password_confirmation.nil?
    crypted_password.blank? || !password.blank?
  end

  def email_present?
    !email.nil?
  end

  def set_access_key
    code = sprintf("%x%x",rand(2147483647),rand(2147483647))
    key = Base64.encode64(code.to_a.pack("H*")).gsub('=', '').tr('+/','-_')
    write_attribute :access_key, key.chomp
  end
end
