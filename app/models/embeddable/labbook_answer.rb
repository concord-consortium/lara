# LabbookAnswer class represents a specific album related to given user, activity run and interactive.
module Embeddable
  class LabbookAnswer < ApplicationRecord
    include Answer

    SOURCE_ID = 'CC_LARA'


    belongs_to :run
    belongs_to :question,
               class_name: 'Embeddable::Labbook',
               foreign_key: 'labbook_id'

    # Theoretically we could send Labbook answer to Portal just once, as its URL shouldn't change.
    # However sending it after each update (in fact "touch") is more bullet-proof and works better
    # in Portal reports - teacher can see whether Labbook album has been actually opened (updated).
    after_update :send_to_portal
    after_update :propagate_to_collaborators

    def self.labbook_provider
      ENV['LABBOOK_PROVIDER_URL']
    end

    delegate :is_upload?,      to: :question
    delegate :is_snapshot?,    to: :question
    delegate :action_label,    to: :question
    delegate :interactive,     to: :question

    def labbook_user_id
      # Construct an unique ID - model ID + run key. Run key is actually unnecessary, but it provides salting,
      # so it's more difficult to access someone's album by constructing Labbook URL manually. Use MD5 hexdigest
      # to mask ID value.
      # It can be confusing that we provide this kind of ID as 'user_id' param. However Labbook service simply merges
      # 'source' and 'user_id' parameters to create the internal album ID. We can provide any values we like.
      # 'user_id' name is not the best one.
      Digest::MD5.hexdigest("#{id}-#{run.key}")
    end

    def album_id
      "source=#{SOURCE_ID}&user_id=#{labbook_user_id}"
    end

    def report_url
      service_url = self.class.labbook_provider
      return nil if service_url.blank?
      "#{service_url}/albums?todo=report&#{album_id}"
    end

    # This method should be called each time when we know (or suspect) that Labbook album content has been changed.
    def mark_updated
      # Note that we can't use #touch method, as it doesn't trigger callbacks.
      self.updated_at = DateTime.now
      save!
    end

    # Answer interface:
    def copy_answer!(another_answer)
      url = "#{self.class.labbook_provider}/albums/replace_all_snapshots"
      response = HTTParty.post(url, {
                   body: {
                     src_source: SOURCE_ID,
                     src_user_id: another_answer.labbook_user_id,
                     dst_source: SOURCE_ID,
                     dst_user_id: labbook_user_id
                   }
                 })
      raise "POST #{url} failed" unless response.success?
      mark_updated # !!!
    end

    def portal_hash
      {
        type: 'external_link',
        question_type: question.class.portal_type,
        question_id: question.portal_id,
        answer: report_url,
        is_final: false
      }
    end

    def report_service_hash
      {
        id: answer_id,
        type: 'external_link',
        question_id: question.embeddable_id,
        question_type: 'iframe_interactive',
        answer: report_url
      }
    end

    def answered?
      # Labbook is an external service, we don't really know its content. However, there is an assumption that once
      # Labbook is opened, `update_at` timestamp is updated and the album link is sent to Portal. So, if `created_at`
      # and `updated_at` are equal, it means that Labbook has never been opened and there can't be any content yet.
      created_at != updated_at
    end
    # End of Answer interface.
  end
end
