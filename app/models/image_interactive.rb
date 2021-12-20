class ImageInteractive < ActiveRecord::Base
  include Embeddable

  attr_accessible :url, :caption, :credit, :show_lightbox, :credit_url, :is_hidden, :is_half_width

  has_one :page_item, :as => :embeddable, :dependent => :destroy
  # PageItem is a join model; if this is deleted, that instance should go too
  has_one :interactive_page, :through => :page_item
  has_one :labbook, :as => :interactive, :class_name => 'Embeddable::Labbook'

  def self.portal_type
    "unsupported"
  end

  def reportable?
    false
  end

  def no_snapshots
    false
  end

  def to_hash
    {
      url: url,
      caption: caption,
      credit: credit,
      credit_url: credit_url,
      is_hidden: is_hidden,
      is_half_width: is_half_width
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
                              :credit_url,
                              :is_half_width,
                              :is_hidden])
  end

  def self.import(import_hash)
    return self.new(import_hash)
  end
end
