LightweightStandalone::Application.config.middleware.use ExceptionNotifier,
  :email_prefix => "[LARA Exception] ",
  :sender_address => %{"notifier" <pmorse+laranotifier@concord.org>},
  :exception_recipients => %w{pmorse@concord.org}
