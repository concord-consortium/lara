class Setting < ApplicationRecord
  validates :key, presence: true
  # value may be empty so no validation needed

  def self.get(key, default_value = nil)
    setting = Setting.find_by_key(key)
    setting ? setting.value : default_value
  end

  def self.set(key, value)
    setting = Setting.find_by_key(key)
    if setting
      setting.value = value
    else
      setting = Setting.new({key: key, value: value})
    end
    setting.save
  end

end
