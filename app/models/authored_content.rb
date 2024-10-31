class AuthoredContent < ApplicationRecord
  # attr_accessible :user, :container, :content_type, :url

  belongs_to :user
  belongs_to :container, polymorphic: true

  def self.create_for_container(create_container, create_user, create_content_type, create_url: nil)
    if create_container.nil?
      raise Exception.new("Authored content container can't be nil")
    end
    if create_user.nil?
      raise Exception.new("Authored content user can't be nil")
    end
    if create_content_type.nil?
      raise Exception.new("Authored content type can't be nil")
    end
    # url can be nil

    self.create(
      user: create_user,
      container: create_container,
      content_type: create_content_type,
      url: create_url
    )
  end
end
