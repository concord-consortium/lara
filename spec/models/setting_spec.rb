require 'spec_helper'

RSpec.describe Setting do
  let(:glossary_setting) { FactoryBot.create(:setting, key: "glossary_approved_script_id", value: "1") }

  it "should provide a self.get method with defaults" do
    glossary_setting
    expect(Setting.get("glossary_approved_script_id")).to eq("1")
    expect(Setting.get("UNKNOWN_SETTING")).to eq(nil)
    expect(Setting.get("UNKNOWN_SETTING", "foo")).to eq("foo")
  end

  it "should provide a self.set method" do
    Setting.set("glossary_approved_script_id", "1000")
    Setting.set("NEW_SETTING", "bar")

    expect(Setting.get("glossary_approved_script_id")).to eq("1000")
    expect(Setting.get("NEW_SETTING")).to eq("bar")
  end
end
