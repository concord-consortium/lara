require 'spec_helper'

describe "sequences/show" do
  before(:each) do
    @sequence = assign(:sequence, stub_model(Sequence,
      :title => "Title",
      :description => "MyText"
    ))
  end

  it "renders attributes" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'div.description', :text => 'MyText'
    assert_select 'div.activities'
  end
end
