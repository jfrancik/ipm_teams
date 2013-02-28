class MyMailer < ActionMailer::Base
  default :from => "jarek@francik.name", :bcc => 'ku32139@kingston.ac.uk'

  def activation_email(user, root_url)
    @user = user
    @root_url = root_url
    mail(:to => @user.e_mail, :subject => "IPM Teams Website - Welcome!")
  end

  def reset_email(user, root_url)
    @user = user
    @root_url = root_url
    mail(:to => @user.e_mail, :subject => "IPM Teams Website - password reset")
  end

  def admin_welcome_email(user, root_url)
    @user = user
    @root_url = root_url
    mail(:to => @user.e_mail, :subject => "IPM Teams Website - welcome!")
    #mail(:to => "ku32139@kingston.ac.uk", :subject => "IPM Teams Website - welcome!")
  end
end
