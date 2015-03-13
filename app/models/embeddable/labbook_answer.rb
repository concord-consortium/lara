# LabbookAnswer class represents a specific album related to given user, activity run and interactive.
module Embeddable
  class LabbookAnswer < ActiveRecord::Base
    include Answer

    SOURCE_ID = 'CC_LARA'

    attr_accessible :run, :question, :is_dirty

    belongs_to :run
    belongs_to :question,
               class_name: 'Embeddable::Labbook',
               foreign_key: 'labbook_id'

    # It's enough to send Labbook to Portal just once - Labbook URL never changes.
    after_create :send_to_portal

    # TODO: run with collaborators support
    # after_update :propagate_to_collaborators

    def self.labbook_provider
      ENV['LABBOOK_PROVIDER_URL']
    end

    delegate :is_upload?, to: :question
    delegate :is_snapshot?, to: :question
    delegate :action_label, to: :question
    delegate :interactive, to: :question

    def album_id
      # Construct unique album ID. Use own ID and run key. Run key is actually unnecessary, but it provides salting,
      # so it's more difficult to access someone's album by constructing Labbook URL manually.
      album_id = "#{id}-#{run.key}"
      # Finally use MD5 hexdigest to mask ID value.
      album_id = Digest::MD5.hexdigest(album_id)
      # It can be confusing that we provide album ID as 'user_id' param. Labbook actually merges 'source' and 'user_id'
      # parameters to create the internal album ID. We can provide any values we like. 'user_id' name is not the best one.
      "source=#{SOURCE_ID}&user_id=#{album_id}"
    end

    def view_url
      service_url = self.class.labbook_provider
      return nil if service_url.blank?
      "#{service_url}/albums?#{album_id}"
    end

    # Answer interface:
    def copy_answer!
      # TODO: run with collaborators support
      # POST "#{self.class.labbook_provider}/albums/copy"
    end

    def portal_hash
      {
        type: 'external_link',
        question_type: question.class.portal_type,
        question_id: question.portal_id,
        answer: view_url,
        is_final: false
      }
    end
    # End of Answer interface.
  end
end

