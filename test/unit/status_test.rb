require 'test_helper'
require 'shoulda'
require 'ostruct'

class StatusTest < ActiveSupport::TestCase
  context "Completing a status" do
    should "mark the most recent status as done" do
      @twitter_mock.should_receive(:direct_messages).once.
        and_return([OpenStruct.new(:sender_id => 1337,
                                   :text => 'Working on something cool',
                                   :id => 88,
                                   :created_at => 10.minutes.ago.to_s(:db)),
                    OpenStruct.new(:sender_id => 1337,
                                   :text => 'done',
                                   :id => 89,
                                   :created_at => 5.minutes.ago.to_s(:db))])
      @twitter_mock.should_receive(:destroy_direct_message).twice.and_return
      assert_difference 'Status.count', 1 do
        Status.import
      end
      created_status = Status.find_by_message('Working on something cool')
      assert_not_nil created_status
      assert created_status.done?
    end
  end

  context "Importing more than 20 statuses" do
    should "get all of them" do
      first_twenty = OpenStruct.new(:sender_id => 1337, :text => 'First twenty', :id => 75)
      second_ten = OpenStruct.new(:sender_id => 1836, :text => 'Second ten', :id => 99)
      @twitter_mock.should_receive(:direct_messages).once.and_return([first_twenty] * 20)
      @twitter_mock.should_receive(:direct_messages).once.and_return([second_ten] * 10)
      @twitter_mock.should_receive(:destroy_direct_message).times(30).and_return

      assert_difference 'Status.count', 30 do
        Status.import
      end
    end
  end

  context "Importing" do
    setup do
      @twitter_mock.should_receive(:direct_messages).once.and_return([OpenStruct.new(:sender_id => 1337, :text => 'Just testing', :id => 15),
         OpenStruct.new(:sender_id => 1836, :text => 'Shoot him!', :id => 17)])
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
