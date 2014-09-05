# encoding: UTF-8
module LocationsHelper
  def current_translations
    @translations ||= I18n.backend.send(:translations)
    trans = @translations[I18n.locale] || @translations[I18n.default_locale]
    return trans.with_indifferent_access.to_json.html_safe
  end
end
