require 'test_helper'
require 'shoulda'
gem 'flexmock'
require 'flexmock'
require 'ostruct'

class StatusTest < ActiveSupport::TestCase
  include FlexMock::TestCase

  context "Importing" do
    setup do
      flexmock(Twitter::Base).new_instances.should_receive(:direct_messages).and_return do
        [OpenStruct.new(:sender_id => 1337, :message => 'Just testing'),
         OpenStruct.new(:sender_id => 1836, :message => 'Shoot him!')]
      end
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
