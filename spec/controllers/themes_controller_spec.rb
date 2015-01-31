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
      expect(assigns(:themes).include?(theme)).to be_truthy
    end
  end

  describe '#new' do
    it 'assigns a new @theme' do
      get :new
      expect(assigns(:theme)).to be_a_new(Theme)
    end
  end

  describe '#edit' do
    it 'assigns the relevant theme to @theme' do
      get :edit, :id => theme.id
      expect(assigns(:theme)).to eq(theme)
    end
  end

  describe '#create' do
    it 'creates a new theme with supplied attributes' do
      oldcount = Theme.count
      put :create, :theme => { :name => 'ThemeName', :css_file => 'themename' }
      expect(response).to redirect_to(edit_theme_path(assigns(:theme)))
      expect(assigns(:theme).name).to eq('ThemeName')
      expect(Theme.count).to be(oldcount + 1)
    end
  end

  describe '#update' do
    it 'updates the specified theme with supplied attributes' do
      post :update, :id => theme.id, :theme => { :css_file => 'newcssmanifest' }
      expect(theme.reload.css_file).to eq('newcssmanifest')
      expect(response).to redirect_to(edit_theme_path(theme))
    end
  end

  describe '#destroy' do
    it 'removes the specified theme from the database' do
      theme = Theme.create(:name => 'Born to die', :css_file => 'temporary')
      expect {
        delete :destroy, {:id => theme.id}
      }.to change(Theme, :count).by(-1)
    end

    it "redirects to the themes list" do
      delete :destroy, {:id => theme.id}
      expect(response).to redirect_to(themes_url)
    end
  end
end
