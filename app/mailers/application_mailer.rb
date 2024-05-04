class ApplicationMailer < ActionMailer::Base
  default from: "Project Manager <manager@gmail.com>"
  layout "mailer"
end
