require File.dirname(__FILE__) + '/../test_helper'
require 'flexmock'

class UserTest < ActiveSupport::TestCase
  include FlexMock::TestCase

  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users

  should "follow a user" do
    ::TWITTER_USER='demo'
    ::TWITTER_PASSWORD='demo'
    user = create_user(:twitter_id => 1337, :twitter_name => 'aaron')
    mock = flexmock(Twitter::Base).new_instances
    mock.should_receive(:create_friendship).once.with(1337).and_return
    mock.should_receive(:follow).once.with(1337).and_return
    user.follow
  end

  context "Creating a new user" do
    should "create the user" do
      assert_difference 'User.count' do
        user = create_user
        assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
      end
    end

    should "require login" do
      assert_no_difference 'User.count' do
        u = create_user(:login => nil)
        assert u.errors.on(:login)
      end
    end

    should "not require a password if both are blank" do
      assert_difference 'User.count' do
        u = create_user(:password => nil, :password_confirmation => nil)
        assert !u.errors.on(:password), u.errors.inspect
      end
    end

    should "require password" do
      assert_no_difference 'User.count' do
        u = create_user(:password => nil)
        assert u.errors.on(:password)
      end
    end

    should "require password confirmation" do
      assert_no_difference 'User.count' do
        u = create_user(:password_confirmation => nil)
        assert u.errors.on(:password_confirmation)
      end
    end

#    should "require email" do
#      assert_no_difference 'User.count' do
#        u = create_user(:email => nil)
#        assert u.errors.on(:email)
#      end
#    end
  end

  should "reset password" do
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin', 'new password')
  end

  should "not rehash password" do
    users(:quentin).update_attributes(:login => 'quentin2')
    assert_equal users(:quentin), User.authenticate('quentin2', 'monkey')
  end

  should "authenticate user" do
    assert_equal users(:quentin), User.authenticate('quentin', 'monkey')
  end

  should "set remember token" do
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  should "unset remember token" do
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end

  should "remember me for one week" do
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  should "remember me until one week" do
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert_equal users(:quentin).remember_token_expires_at, time
  end

  should "remember me default two weeks" do
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

protected
  def create_user(options = {})
    record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.save
    record
  end
end
