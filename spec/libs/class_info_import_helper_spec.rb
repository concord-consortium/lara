# spec/lib/class_info_import_helper_spec.rb
require 'spec_helper'
require 'class_info_import_helper'

describe ClassInfoImportHelper do
  let(:clazz_id)    { 123 }
  let(:learner_id)  { 456 }
  let(:class_hash)  { "C842239D-6447-4CED-89AD-44DD21A9012F" }
  let(:learner_key) { "EDAC877F-209D-494D-B0CB-6F0CE3E577CD" }
  before(:each) do
    allow(ENV).to receive(:[])
    .with("IMPORT_PORTAL_URL")
    .and_return("http://app.portal.docker/")
  end
  let(:line_with_all_fields) do
    "#{clazz_id}, #{class_hash}, #{learner_id}, #{learner_key}"
  end
  let(:line_missing_learner_key) do
    "#{clazz_id}, #{class_hash}, #{learner_id}, "
  end

  describe "remote_endpoint_path" do
    describe "with all fields" do
      let(:line) { line_with_all_fields }
      it "should use the learner_key for the remote endpoint url" do
        remote_endpoint = ClassInfoImportHelper.remote_endpoint_path_for(line)
        expected_enpoint = "http://app.portal.docker//dataservice/external_activity_data/EDAC877F-209D-494D-B0CB-6F0CE3E577CD"
        expect(remote_endpoint).to eql expected_enpoint
      end
    end

    describe "when missing the learner_key" do
      let(:line) { line_missing_learner_key }
      it "should use the learner_id for the remote endpoint url" do
        remote_endpoint = ClassInfoImportHelper.remote_endpoint_path_for(line)
        expected_enpoint = "http://app.portal.docker//dataservice/external_activity_data/456"
        expect(remote_endpoint).to eql expected_enpoint
      end
    end
  end
end