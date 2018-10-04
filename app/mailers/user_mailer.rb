class UserMailer < ActionMailer::Base
  default from: "test@test.com"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.sendMail.subject
  #
  def sendMail(email,email1)
    @greeting = "Hi"
    @from = email1
    mail to: email, subject: "You have an new Opinion."
  end
  def forgotPassword(email)
    @greeting = "Hi"
    p @email = email
    mail to: email, subject: "Reset Password link sent to you..."
  end
end
