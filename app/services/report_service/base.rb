module ReportService
  module Base

    KeyRegex = /(\.|\/)+/
    UrlRegex = /https?:\/\/([^\/]+)/
    KeyReplacement = "_"
    KeyJoiner = "-"

    def make_key(*values)
      key = values.join(KeyJoiner)
      key.gsub(KeyRegex, KeyReplacement)
    end

    def make_source_key(url)
      make_key(url.gsub(UrlRegex, '\1'))
    end

  end
end