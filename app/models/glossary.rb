class Glossary < ActiveRecord::Base
  attr_accessible :name, :json, :user_id
  validates :name, presence: true
  validates :user_id, presence: true

  belongs_to :user
  has_many :lightweight_activities

  def export
    {
      id: self.id,
      name: self.name,
      user_id: self.user_id,
      json: JSON.parse(json, symbolize_names: true)
    }
  end

  def export_json_only
    JSON.parse(json, symbolize_names: true)
  end

  def self.by_author(user)
    if user
      self.where(user_id: user.id).order(:name)
    else
      []
    end
  end

end
