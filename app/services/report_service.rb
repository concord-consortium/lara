module ReportService
  KeyRegex = /(\.|\/)+/
  UrlRegex = /https?:\/\/([^\/]+)/
  KeyReplacement = "_"
  KeyJoiner = "-"

  def self.make_key(*values)
    key = values.join(KeyJoiner)
    key.gsub(KeyRegex, KeyReplacement)
  end

  def self.make_source_key(url)
    make_key(url.gsub(UrlRegex, '\1'))
  end

  def self.configured?()
    ENV['REPORT_SERVICE_TOKEN'].present? &&
    ENV['REPORT_SERVICE_URL'].present? &&
    ENV['REPORT_SERVICE_SELF_URL'].present?
  end

end
