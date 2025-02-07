class DevController < ActionController::Base
  def test_mail
    recipient = "authoring-help@concord.org"
    MailTest.test(recipient, request).deliver
    flash[:notice]= "A test message has been sent to #{recipient}"
    redirect_to "/"
  end

  def test_error
    MailTest.test_error(request)
  end


end