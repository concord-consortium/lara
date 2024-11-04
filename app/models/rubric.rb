class Rubric < ApplicationRecord
  # attr_accessible :name, :user_id, :project_id, :project, :authored_content_id, :authored_content, :doc_url
  validates :name, presence: true
  validates :user_id, presence: true

  belongs_to :user
  belongs_to :project
  has_one :authored_content, as: :container
  has_many :lightweight_activities

  after_create :create_authored_content

  # scope :public, self.scoped # all rubrics are public
  scope :is_public, -> { self.all }
  scope :no_rubrics, -> { where("1 = 0") } # used to return "my rubrics" to no user
  scope :newest, -> { order(updated_at: :desc) }

  def export(user)
    {
      id: self.id,
      name: self.name,
      project: self.project ? self.project.export : nil,
      user_id: self.user_id,
      doc_url: self.doc_url,
      can_edit: self.can_edit(user)
    }
  end

  def to_hash
    {
      id: self.id,
      name: self.name,
      project: self.project,
      user_id: self.user_id,
      doc_url: self.doc_url
    }
  end

  def to_export_hash
    {
      id: self.id,
      name: self.name,
      project: self.project,
      user_id: self.user_id,
      doc_url: self.doc_url,
      type: "Rubric"
    }
  end

  def duplicate(new_owner)
    new_rubric = Rubric.new(self.to_hash.except(:id))
    new_rubric.name = "Copy of #{new_rubric.name}"
    new_rubric.user = new_owner
    new_rubric
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

  def create_authored_content
    if !self.authored_content
      self.authored_content = AuthoredContent.create_for_container(self, user, "application/json")
      self.save!
      self.reload
    end
  end

  def self.import(rubric_json_object, new_owner)
    imported_rubric = Rubric.new(self.extract_from_hash(rubric_json_object))
    imported_rubric.project = Project.find_or_create(rubric_json_object[:project]) if rubric_json_object[:project]
    imported_rubric.user = new_owner
    imported_rubric.save!
    imported_rubric
  end

  def self.extract_from_hash(rubric_json_object)
    {
      name: rubric_json_object[:name]
    }
  end

  # helper used in lightweight activity edit to list the rubrics that can be assigned to an activity
  def self.by_author(user)
    if user
      self.where(user_id: user.id).eager_load(:user).order(:name)
    else
      self.no_rubrics
    end
  end

  # helper used in lightweight activity edit to list the rubrics that can be assigned to an activity
  def self.by_others(user)
    if user
      self.where("user_id != ?", user.id).eager_load(:user).order(:name)
    else
      self.all.eager_load(:user).order(:name)
    end
  end

  # Class methods below are to enable rubric listing on the homepage through the collection filter
  # These somewhat mirror the class methods injects by the PublicationStatus model, except they remove
  # the checks for publication status
  def self.my(user)
    where(user_id: user.id)
  end

  def self.can_see(user)
    # all users can see all rubrics
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
      self.no_rubrics
    end
  end
end
