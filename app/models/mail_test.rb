class MailTest < ActionMailer::Base
  default from: 'authoring-help@concord.org'

  def test(to="authoring-help@concord.org",req=nil)
    req ||= OpenStruct.new(host: 'unknown', remote_ip: 'unknown')
    message =<<-EOF
      This is a test message from LARA, verifying that 
      ActionMailer is configured corectly, and can communicate
      with the outside world.

      TIME:   #{Time.now}
      HOST:   #{req.host}
      REMOTE: #{req.remote_ip}
    EOF
    mail(to: to, subject: 'LARA ActionMailer Test', body: message)
  end

  def test_error(req)
    raise "This is a test of the ExceptionNotifier from LARA #{req.host}"
  end
end
