require 'spec_helper'
require 'will_paginate/array'

describe "sequences/index" do

  before(:each) do
    a = stub_model(Sequence,
        title: "Title",
        description: "MyText",
        updated_at: "2013-06-19 19:32:33"
      )
    b = stub_model(Sequence,
        title: "Title",
        description: "MyText",
        updated_at: "2013-06-19 19:32:34"
      )
    sequences = [a,b].paginate()
    assign(:sequences,sequences)
  end

  it "renders a list of sequences" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "div.action_menu_header_left>a", text: "Title".to_s, count: 2
    assert_select "div.tiny", count: 2
  end

  it "renders copy link" do
    user ||= FactoryGirl.create(:admin)
    sign_in user
    render
    assert_select ".copy", count: 2
  end
end
