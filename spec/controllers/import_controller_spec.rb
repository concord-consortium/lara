require 'spec_helper'
describe ImportController do
  
  before(:each) do
    @user ||= FactoryGirl.create(:admin)
    sign_in @user
  end

  describe 'routing' do
    
    it 'recognizes and generates #import_status' do
      expect({:get => "/import"}).
        to route_to({
          :controller       => 'import', 
          :action           => 'import_status'
      })
    end
    
  end  
  
  describe '#import' do
    
    context "lightweight activity" do 
      
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
      
      it "can import a lightweight activity from a valid lightweight activity json and redirect to edit page" do
        xhr :post, "import", params1
        expect(assigns(:import_item)).to be_a(LightweightActivity)
        expect(response.content_type).to eq("text/javascript")
        expect(response.body).to eq("window.location.href = 'activities/#{assigns(:import_item).id}/edit'\;")
      end
      
      it "response status 500 error if import fails" do
        xhr :post, "import", params2
        response.status == 500
        expect(response.body).to eq("{\"error\":\"Import failed because of invalid JSON file.\"}")
      end
      
    end
    
     context "Sequence" do 
      
      valid_sequence_import_json = File.new(Rails.root + 'spec/import_examples/valid_sequence_import.json')
      let(:params1) do
            {
               import:{
                 import:ActionDispatch::Http::UploadedFile.new(tempfile: valid_sequence_import_json, filename: File.basename(valid_sequence_import_json), content_type: "application/json")
               } 
               
            }
      end
      invalid_sequence_import_json = File.new(Rails.root + 'spec/import_examples/invalid_sequence_import.json')
      let(:params2) do
            {
               import:{
                 import:ActionDispatch::Http::UploadedFile.new(tempfile: invalid_sequence_import_json, filename: File.basename(invalid_sequence_import_json), content_type: "application/json")
               } 
               
            }
      end
      
      it "can import a sequence from a valid sequence json and redirect to edit page" do
        xhr :post, "import", params1
        expect(assigns(:import_item)).to be_a(Sequence)
        expect(response.content_type).to eq("text/javascript")
        expect(response.body).to eq("window.location.href = 'sequences/#{assigns(:import_item).id}/edit'\;")
      end
      
      it "response status 500 error if import fails" do
        xhr :post, "import", params2
        response.status == 500
        expect(response.body).to eq("{\"error\":\"Import failed because of invalid JSON file.\"}")
      end
    end
    
  end
end
