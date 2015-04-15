class UnauthorizedFeedbackMailer < ActionMailer::Base
  default from: 'authoring-help@concord.org'
  append_view_path File.expand_path('lib/exception_notifier/views', Gem.loaded_specs['exception_notification'].full_gem_path)

  helper_method :inspect_object

  def inspect_object(object)
    case object
      when Hash, Array
        object.inspect
      else
        object.to_s
    end
  end

  def feedback(info, to='authoring-help@concord.org')
    @info = info
    @request = info[:request]
    @session = info[:session]
    @env = info[:request].env
    @sections = [:request, :session, :environment]
    mail(to: to, subject: 'LARA Feedback (Session Expired)')
  end
end
