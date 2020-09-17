LightweightStandalone::Application.config.middleware.use ExceptionNotification::Rack,
:email => {
  :email_prefix => "[LARA Exception] ",
  :sender_address => %{"notifier" <authoring-help@concord.org>},
  :exception_recipients => %w{all-portal-errors@concord.org}
}
