class BugMailer < ApplicationMailer

  def notify_bug_assignment
    @greeting = "Hi"
    @user = params[:user]
    @bug = params[:bug]

    mail(
      from: "Team <projectteam@gmail.com>",
      to: email_address_with_name(@user.email, @user.name),
      subject: 'You have successfully assigned a bug to yourself'
    )
  end

  def notify_bug_status
    @greeting = "Hi"
    @user = params[:user]
    @bug = params[:bug]

    mail(
      from: "Team <projectteam@gmail.com>",
      to: email_address_with_name(@user.email, @user.name),
      subject: 'Bug status updated successfully',
      cc: User.manager.first.email
    )
  end

  def notify_bug_creation
    @greeting = "Hi"
    @bug = params[:bug]

    mail(
      from: "Team <projectteam@gmail.com>",
      to: User.manager.first.email,
      subject: 'A new bug has been created',
      cc: @bug.project.users.pluck(:email)
    )
  end
end
