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
    url.gsub(UrlRegex, '\1')
  end
end
