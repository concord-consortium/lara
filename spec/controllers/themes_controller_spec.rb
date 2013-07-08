require 'spec_helper'

describe ThemesController do
  let (:theme) { FactoryGirl.create(:theme) }

  before(:each) do
    # We're testing access control in spec/models/user_spec.rb, so for this
    # suite we use a user with global permissions
    @user ||= FactoryGirl.create(:admin)
    sign_in @user
  end

  describe '#index' do
    it 'includes theme in an assigns' do
      theme
      get :index
      assigns(:themes).include?(theme).should be_true
    end
  end

  describe '#new' do
    it 'assigns a new @theme' do
      get :new
      assigns(:theme).should be_a_new(Theme)
    end
  end

  describe '#edit' do
    it 'assigns the relevant theme to @theme' do
      get :edit, :id => theme.id
      assigns(:theme).should == theme
    end
  end

  describe '#create' do
    it 'creates a new theme with supplied attributes' do
      pending "Write this test"
    end
  end

  describe '#update' do
    it 'updates the specified theme with supplied attributes' do
      pending "Write this test"
    end
  end
end
