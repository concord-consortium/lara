module Embeddable
  class ModelFeedback < ActiveRecord::Base
    include Embeddable

    attr_accessible :url, :name
    # PageItem instances are join models, so if the embeddable is gone the join should go too.

    has_many :page_items, :as => :embeddable, :dependent => :destroy
    has_many :interactive_pages, :through => :page_items

    def self.name_as_param
      :embeddable_model_feedback
    end

    def self.display_partial
      :model_feedback
    end

    def self.human_description
      "Model Feedback"
    end

    def self.import(import_hash)
      return self.new(import_hash)
    end

    def to_hash
      {
        name: name,
        url: url
      }
    end

    def portal_hash
      {
        type: "modelfeedback",
        id: id,
        url: url,
        name: name
      }
    end

    def duplicate
      return Embeddable::ModelFeedback.new(self.to_hash)
    end

    def reportable?
      false
    end

    def is_hidden
      false
    end

    def export
      return self.as_json(only:[:name, :url])
    end

  end
end
