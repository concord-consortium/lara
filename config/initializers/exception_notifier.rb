LightweightStandalone::Application.config.middleware.use ExceptionNotification::Rack,
:email => {
  :email_prefix => "[LARA Exception] ",
  :sender_address => %{"notifier" <pmorse+laranotifier@concord.org>},
  :exception_recipients => %w{npaessel@concord.org}
}
