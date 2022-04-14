class Glossary < ActiveRecord::Base
  attr_accessible :name, :json, :user_id
  validates :name, presence: true
  validates :user_id, presence: true

  belongs_to :user
  has_many :lightweight_activities

  scope :public, where("1 = 0") # There are no public glossaries, this is used by the CollectionFilter
  scope :newest, order("updated_at DESC")

  def export
    {
      id: self.id,
      name: self.name,
      user_id: self.user_id,
      json: self.export_json_only
    }
  end

  def export_json_only
    JSON.parse(json || "{}", symbolize_names: true)
  end

  def to_hash
    {
      id: self.id,
      name: self.name,
      user_id: self.user_id,
      json: self.json || "{}"
    }
  end

  def to_export_hash
    {
      id: self.id,
      name: self.name,
      user_id: self.user_id,
      json: self.json || "{}",
      type: "Glossary"
    }
  end

  def duplicate(new_owner)
    new_glossary = Glossary.new(self.to_hash)
    new_glossary.name = "Copy of #{new_glossary.name}"
    new_glossary.user = new_owner
    new_glossary
  end

  def self.import(glossary_json_object, new_owner)
    imported_glossary = Glossary.new(self.extract_from_hash(glossary_json_object))
    imported_glossary.user = new_owner
    imported_glossary.save!
    imported_glossary
  end

  def self.extract_from_hash(glossary_json_object)
    {
      name: glossary_json_object[:name],
      json: glossary_json_object[:json]
    }
  end

  def self.get_glossary_approved_script()
    # for now we just return the first approved script named glossary, this should be
    # changed before the final delivery to add an admin setting for the approved glossary script
    ApprovedScript.find_by_label("glossary")
  end

  # helper used in lightweight activity edit to list the glossaries that can be assigned to an activity
  def self.by_author(user)
    if user
      self.where(user_id: user.id).order(:name)
    else
      self.public # this defaults to an empty relation
    end
  end

  # Class methods below are to enable glossary listing on the homepage through the collection filter
  # These somewhat mirror the class methods injects by the PublicationStatus model, except they remove
  # the checks for publication status
  def self.my(user)
    where(:user_id => user.id)
  end

  def self.can_see(user)
    if user.admin?
      self.scoped # admins can see all glossaries
    else
      self.my(user)
    end
  end

  def self.visible(user)
    self.can_see(user)
  end

  def self.search(query, user)
    self.can_see(user).where("name LIKE ?", "%#{query}%")
  end
end
