require 'spec_helper'
describe ImportController do
  
  before(:each) do
    @user ||= FactoryGirl.create(:admin)
    sign_in @user
  end

  describe 'routing' do
    
    it 'recognizes and generates #import_status' do
      {:get => "/import"}.
        should route_to({
          :controller       => 'import', 
          :action           => 'import_status'
      })
    end
    
  end  
  
  describe '#import' do
    valid_activity_import_json = File.new(Rails.root + 'spec/import_examples/valid_lightweight_activity_import.json')
    let(:params1) do
          {
             import:{
               import:ActionDispatch::Http::UploadedFile.new(tempfile: valid_activity_import_json, filename: File.basename(valid_activity_import_json), content_type: "application/json")
             } 
             
          }
    end
    invalid_activity_import_json = File.new(Rails.root + 'spec/import_examples/invalid_lightweight_activity_import.json')
    let(:params2) do
          {
             import:{
               import:ActionDispatch::Http::UploadedFile.new(tempfile: invalid_activity_import_json, filename: File.basename(invalid_activity_import_json), content_type: "application/json")
             } 
             
          }
    end
    
    context "lightweight activity" do 
      it "can import a lightweight activity from a valid lightweight activity json and redirect to edit page" do
        post "import", params1
        assigns(:import_activity).should be_a(LightweightActivity)
        response.should redirect_to(edit_activity_url(assigns(:import_activity)))
      end
      
      it "flashes warning if import fails" do
        post "import", params2
        flash[:warning].should_not be_nil
        response.should redirect_to(activities_path)
      end
    end

  end
  
end
