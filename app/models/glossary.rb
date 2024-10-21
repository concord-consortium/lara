class Glossary < ActiveRecord::Base
  attr_accessible :name, :json, :user_id, :legacy_glossary_resource_id, :project_id, :project
  validates :name, presence: true
  validates :user_id, presence: true

  belongs_to :user
  belongs_to :project
  has_many :lightweight_activities

  # scope :public, self.scoped # all glossaries are public
  scope :none, -> { where("1 = 0") } # used to return "my glossaries" to no user
  scope :newest, -> { order(updated_at: :desc) }

  def export(user)
    {
      id: self.id,
      name: self.name,
      project: self.project ? self.project.export : nil,
      user_id: self.user_id,
      can_edit: self.can_edit(user),
      legacy_glossary_resource_id: self.legacy_glossary_resource_id,
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
      project: self.project,
      user_id: self.user_id,
      legacy_glossary_resource_id: self.legacy_glossary_resource_id,
      json: self.json || "{}"
    }
  end

  def to_export_hash
    {
      id: self.id,
      name: self.name,
      project: self.project,
      user_id: self.user_id,
      legacy_glossary_resource_id: self.legacy_glossary_resource_id,
      json: self.json || "{}",
      type: "Glossary"
    }
  end

  def duplicate(new_owner)
    new_glossary = Glossary.new(self.to_hash)
    new_glossary.name = "Copy of #{new_glossary.name}"
    new_glossary.legacy_glossary_resource_id = nil
    new_glossary.user = new_owner
    new_glossary
  end

  def can_edit(user)
    if user.nil?
      false
    else
      user.id == self.user_id || user.admin? || user.project_admin_of?(self.project)
    end
  end

  def can_delete()
    self.lightweight_activities.length == 0
  end

  def self.import(glossary_json_object, new_owner)
    imported_glossary = Glossary.new(self.extract_from_hash(glossary_json_object))
    imported_glossary.project = Project.find_or_create(glossary_json_object[:project]) if glossary_json_object[:project]
    imported_glossary.user = new_owner
    imported_glossary.save!
    imported_glossary
  end

  def self.extract_from_hash(glossary_json_object)
    {
      name: glossary_json_object[:name],
      json: glossary_json_object[:json],
      legacy_glossary_resource_id: glossary_json_object[:legacy_glossary_resource_id]
    }
  end

  def self.get_glossary_approved_script()
    # if no glossary is selected in the settings, return the first one found
    approved_script_id = Setting.get("glossary_approved_script_id")
    selected_glossary = ApprovedScript.find_by_id(approved_script_id) if approved_script_id
    default_glossary = ApprovedScript.find_by_label("glossary") unless selected_glossary
    selected_glossary || default_glossary
  end

  # helper used in lightweight activity edit to list the glossaries that can be assigned to an activity
  def self.by_author(user)
    if user
      self.where(user_id: user.id).eager_load(:user).order(:name)
    else
      self.none
    end
  end

  # helper used in lightweight activity edit to list the glossaries that can be assigned to an activity
  def self.by_others(user)
    if user
      self.where("user_id != ?", user.id).eager_load(:user).order(:name)
    else
      self.all.eager_load(:user).order(:name)
    end
  end

  # Class methods below are to enable glossary listing on the homepage through the collection filter
  # These somewhat mirror the class methods injects by the PublicationStatus model, except they remove
  # the checks for publication status
  def self.my(user)
    where(:user_id => user.id)
  end

  def self.can_see(user)
    # all users can see all glossaries
    self.all
  end

  def self.visible(user)
    self.can_see(user)
  end

  def self.search(query, user)
    self.can_see(user).where("name LIKE ?", "%#{query}%")
  end

  def self.public_for_user(user)
    if user && (user.admin? || user.author? || user.project_admin_of?(self.project))
      self.all
    else
      self.none
    end
  end
end
