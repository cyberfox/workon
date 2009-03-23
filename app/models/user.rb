require 'digest/sha1'

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

  def follow
    twitter = Twitter::Base.new(TWITTER_USER, TWITTER_PASSWORD)
    twitter.create_friendship(twitter_id)
    twitter.follow(twitter_id)
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
    write_attribute :access_key, sprintf("%x%x",rand(2147483647),rand(2147483647))
  end
end
