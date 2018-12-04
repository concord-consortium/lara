require 'spec_helper'

describe 'shared/_analytics' do

  describe "Google analytics support" do
    let(:script_regex) { "ga('send', 'pageview');"}

    describe "With a GA token" do
      before(:each) do
        ENV['GOOGLE_ANALYTICS_ACCOUNT'] = 'fake-ga-account'
      end

      it "should render the analytics javascript" do
        render
        expect(rendered).to include script_regex
      end
    end
    describe "without a GA token" do
      before(:each) do
        ENV['GOOGLE_ANALYTICS_ACCOUNT'] = nil
      end
      it "should not render the analytics javascript" do
        render
        expect(rendered).to_not include script_regex
      end
    end
  end
end
