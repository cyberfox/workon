class MailProcessor
  def self.receive(body)
    email = TMail::Mail.parse(body)
    twtype = email.header_string('X-Twitteremailtype')

    if(twtype == 'is_following')
      twid = email.header_string('X-Twittersenderid')
      twname = email.header_string('X-Twittersenderscreenname')
      twfull = email.header_string('X-Twittersendername')

      new_user = User.find_by_twitter_id(twid)
      new_user ||= User.create(:login => twname, :name => twfull, :twitter_id => twid, :twitter_name => twname)
      new_user.follow
    end
  end
end
