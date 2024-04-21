class PostMailer < ApplicationMailer
  default from: "email@yourdomain.org"

  def notification_email
    mail(to: "personal@gmail.com", subject: "Notification about the new post")
  end
end
