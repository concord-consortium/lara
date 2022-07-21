require 'spec_helper'

describe "lara2:migrate_glossary_plugins" do
  include_context "rake"

  let(:glossary)      { nil }
  let(:plugins)       { [] }
  let(:author)        { FactoryGirl.create(:author) }
  let(:activity_opts) { {user: author, glossary: glossary, plugins: plugins} }
  let(:activity)      { FactoryGirl.create(:activity, activity_opts) }

  let(:approved_script) { FactoryGirl.create(:approved_script, label: "glossary") }

  it "skips activities without glossary plugins" do
    activity
    expect(activity.glossary_id).to be_nil
    expect(activity.plugins.length).to eq(0)

    subject.invoke

    activity.reload
    expect(activity.glossary_id).to be_nil
    expect(activity.plugins.length).to eq(0)
  end

  describe "activities that already have a glossary model id set" do
    let(:glossary) { FactoryGirl.create(:glossary, name: "New Glossary", user: author) }

    it "skips the migration" do
      activity
      expect(activity.glossary_id).to eq(glossary.id)
      expect(activity.plugins.length).to eq(0)

      subject.invoke

      activity.reload
      expect(activity.glossary_id).to eq(glossary.id)
      expect(activity.plugins.length).to eq(0)
    end
  end

  describe "activities with a glossary plugin whose resource id doesn't match any glossaries" do
    let(:plugins) { [
      FactoryGirl.create(:plugin,
        approved_script: approved_script,
        component_label: "glossary", 
        author_data: "{\"glossaryResourceId\":\"NO-MATCHING-ID\"}"
      )
    ]}

    it "skips the migration" do
      activity
      expect(activity.glossary_id).to be_nil
      expect(activity.plugins.length).to eq(1)

      subject.invoke

      activity.reload
      expect(activity.glossary_id).to be_nil
      expect(activity.plugins.length).to eq(1)
    end
  end  

  describe "activities with a glossary plugin whose resource id matches a glossary" do
    let(:legacy_glossary) { FactoryGirl.create(:glossary, name: "Glossary", user: author, legacy_glossary_resource_id: "MATCHING-ID") }
    let(:plugins) { [
      FactoryGirl.create(:plugin,
        approved_script: approved_script,
        component_label: "glossary", 
        author_data: "{\"glossaryResourceId\":\"MATCHING-ID\"}"
      )
    ]}

    it "migrates to the glossary model" do
      legacy_glossary
      activity
      expect(activity.glossary_id).to be_nil
      expect(activity.plugins.length).to eq(1)

      subject.invoke

      activity.reload
      expect(activity.glossary_id).to eq(legacy_glossary.id)
      expect(activity.plugins.length).to eq(1)
    end  
  end
end

describe "lara2:permanently_delete_glossary_plugins" do
  include_context "rake"
  
  let(:author)        { FactoryGirl.create(:author) }
  let(:activity)      { FactoryGirl.create(:activity, user: author) }
  let(:approved_script) { FactoryGirl.create(:approved_script, label: "glossary") }
  let(:plugins) { [
    FactoryGirl.create(:plugin,
      approved_script: approved_script,
      component_label: "glossary"
    ),
    FactoryGirl.create(:plugin,
      approved_script: approved_script,
      component_label: "not-a-glossary"
    )
  ]}

  before(:each) do
    plugins.each { |p| activity.plugins.push(p) }
  end

  it "skips it when the incorrect prompt value is entered" do
    allow(STDIN).to receive(:gets).and_return('NO!')
    
    expect(activity.plugins.length).to eq(2)
    subject.invoke
    activity.reload
    expect(activity.plugins.length).to eq(2)
  end

  it "runs it when the correct prompt value is entered" do
    allow(STDIN).to receive(:gets).and_return('YES')
    
    expect(activity.plugins.length).to eq(2)
    subject.invoke
    activity.reload
    expect(activity.plugins.length).to eq(1)
    expect(activity.plugins[0].component_label).to eq("not-a-glossary")
  end
end