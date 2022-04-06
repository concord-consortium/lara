class Glossary < ActiveRecord::Base
  attr_accessible :name, :json, :user_id

  belongs_to :user
  has_many :lightweight_activities

  def to_json()
    result = self.as_json(only: [:id, :name, :user_id ])
    result["json"] = JSON.parse(json)
    result
  end

end
