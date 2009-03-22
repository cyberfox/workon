require 'test_helper'
require 'shoulda'
require 'ostruct'

class StatusTest < ActiveSupport::TestCase
  context "Importing" do
    setup do
      @twitter_mock.should_receive(:direct_messages).once.and_return([OpenStruct.new(:sender_id => 1337, :message => 'Just testing', :id => 15),
         OpenStruct.new(:sender_id => 1836, :message => 'Shoot him!', :id => 17)])
      @twitter_mock.should_receive(:destroy_direct_message).twice.and_return
    end

    should "be successful" do
      assert_difference 'Status.count', 2 do
        Status.import
      end
    end

    context "" do
      setup do
        Status.import
      end

      should "result in 3 statuses for quentin" do
        assert_equal 3, users(:quentin).statuses.length
      end

      should "result in 1 status for aaron" do
        assert_equal 1, users(:aaron).statuses.length
      end
    end
  end
end
