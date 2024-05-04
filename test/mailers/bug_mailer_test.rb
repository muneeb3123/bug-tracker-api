require "test_helper"

class BugMailerTest < ActionMailer::TestCase
  test "notify_bug_assignment" do
    mail = BugMailer.notify_bug_assignment
    assert_equal "Notify bug assignment", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "notify_bug_status" do
    mail = BugMailer.notify_bug_status
    assert_equal "Notify bug status", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "notify_bug_creation" do
    mail = BugMailer.notify_bug_creation
    assert_equal "Notify bug creation", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
