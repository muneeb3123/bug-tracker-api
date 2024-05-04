# Preview all emails at http://localhost:3000/rails/mailers/bug_mailer
class BugMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/bug_mailer/notify_bug_assignment
  def notify_bug_assignment
    BugMailer.notify_bug_assignment
  end

  # Preview this email at http://localhost:3000/rails/mailers/bug_mailer/notify_bug_status
  def notify_bug_status
    BugMailer.notify_bug_status
  end

end
