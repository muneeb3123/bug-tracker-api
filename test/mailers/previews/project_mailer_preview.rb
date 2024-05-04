# Preview all emails at http://localhost:3000/rails/mailers/project_mailer
class ProjectMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/project_mailer/notify_user_assignment
  def notify_user_assignment
    ProjectMailer.with(user: User.first, project: Project.first ).notify_user_assignment.deliver_now
  end

end
