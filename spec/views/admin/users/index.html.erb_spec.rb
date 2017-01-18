require 'spec_helper'

describe "admin/users/index" do
  before(:each) do
    assign(:users, users)
  end
  let(:users) do
    users =[ stub_model(User), stub_model(User) ]
    WillPaginate::Collection.create(1, 10, users.length) do |pager|
      pager.replace users
    end
  end

  it "renders a list of users" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers

    assert_select 'td'
  end
end
