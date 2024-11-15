class ImageInteractive < ApplicationRecord
  include Embeddable


  has_many :page_items, as: :embeddable, dependent: :destroy
  # PageItem is a join model; if this is deleted, that instance should go too
  has_one :converted_interactive, class_name: "ManagedInteractive", as: :legacy_ref
  has_many :embeddable_plugins, class_name: "Embeddable::EmbeddablePlugin", as: :embeddable
  has_many :interactive_pages, through: :page_items
  has_one :labbook, as: :interactive, class_name: 'Embeddable::Labbook'

  def self.portal_type
    "unsupported"
  end

  def reportable?
    false
  end
  
  def page_section
    # In practice one question can't be added to multiple pages. Perhaps it should be refactored to has_one / belongs_to relation.
    page_items.count > 0 && page_items.first.section
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
