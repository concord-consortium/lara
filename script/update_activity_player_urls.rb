# This is intended to be run in the Portal.
# It was needed to handle a change in the URL format published by LARA version 1.60.0 
tool = Tool.where(name: "ActivityPlayer").first
ExternalActivity.where(tool: tool).find_each{ |ea|
  resource_url = ea.url
  uri = URI.parse(resource_url)
  query = Rack::Utils.parse_query(uri.query)
  uri.query = Rack::Utils.build_query(query)
  puts uri.to_s
  ea.update_attributes(url: uri.to_s)
}
ExternalActivity.where(tool: tool).pluck(:url).each{|url| puts url}; nil
