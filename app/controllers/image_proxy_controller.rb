# Simple proxy used by Drawing Tool.
class ImageProxyController < ActionController::Base
  def get
    raw_url = params[:url]
    raw_url = "http://#{raw_url}" if !(raw_url =~ /http/)
    url = URI.parse(raw_url)
    http = Net::HTTP.new url.host, url.port
    http.use_ssl = true if url.scheme == 'https'
    image = http.start { |agent| agent.get(url.path) }
    send_data image.body, type: image.content_type, disposition: 'inline'
  end
end
