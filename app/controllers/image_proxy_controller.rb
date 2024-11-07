# Simple proxy used by Drawing Tool.
class ImageProxyController < ActionController::Base
  def get
    response = HTTParty.get params[:url], redirect: true
    raise Net::HTTPError if response.code != 200
    send_data response.body, type: response.headers['content-type'], disposition: 'inline'
  rescue
    head :bad_gateway
  end
end
