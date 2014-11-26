class ImageInteractive < ActiveRecord::Base
  attr_accessible :url, :caption, :credit, :show_lightbox, :credit_url

  has_one :interactive_item, :as => :interactive, :dependent => :destroy
  # InteractiveItem is a join model; if this is deleted, that instance should go too

  has_one :interactive_page, :through => :interactive_item

  def self.string_name
    "image interactive"
  end

  def to_hash
    {
      url: url,
      caption: caption,
      credit: credit,
      credit_url: credit_url
    }
  end

  def duplicate
    return ImageInteractive.new(self.to_hash)
  end

  def credit_with_link
    html_credit =  (self.credit || "").html_safe
    return html_credit if self.credit_url.blank?
    return "<a href='#{self.credit_url}' target='_blank'>#{self.credit}</a>".html_safe
  end
  
  def export
    return self.as_json(only:[:caption, 
                              :url, 
                              :credit, 
                              :credit_url])
  end
  
  def self.import(import_hash)
    return self.new(import_hash)
  end
end
