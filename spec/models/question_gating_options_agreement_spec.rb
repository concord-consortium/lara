require 'spec_helper'

describe QuestionGating do
  it "allows the same values the authoring select offers" do
    source = File.read(Rails.root.join("lara-typescript/src/page-item-authoring/common/components/question-gating-options.tsx"))
    options = source[/QUESTION_GATING_OPTIONS[^=]*=\s*\[(.*?)\];/m, 1]
    expect(options).not_to be_nil
    expect(options.scan(/value: "([^"]+)"/).flatten).to eq QuestionGating::VALUES
  end
end
