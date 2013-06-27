require 'spec_helper'

describe HomeController do
  let (:activity) { FactoryGirl.create(:public_activity) }
  let (:sequence) { FactoryGirl.create(:sequence) }

  describe '#home' do
    it 'has 10 or fewer activities' do
      activity
      get :home
      assigns(:activities).first.should be_a_kind_of(LightweightActivity)
      assigns(:activities).length.should be < 11
    end

    it 'has 10 or fewer sequences' do
      sequence
      get :home
      assigns(:sequences).first.should be_a_kind_of(Sequence)
      assigns(:sequences).length.should be < 11
    end
  end
end
