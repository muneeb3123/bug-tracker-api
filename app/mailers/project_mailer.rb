class ProjectMailer < ApplicationMailer

  def notify_user_assignment
    @user = params[:user]
    @project = params[:project]

    mail(to: email_address_with_name(@user.email, @user.name), subject: "You have been assigned a new project")
  end

  def notify_user_removal
    @user = params[:user]
    @project = params[:project]

    mail(to: email_address_with_name(@user.email, @user.name), subject: "You have been removed from a project")
  end
end
