require 'spec_helper'

describe "WithPlatformInfo" do

  class HasPlatformInfo
    include WithPlatformInfo
    attr_accessor :class_info_url
    attr_accessor :context_id
    attr_accessor :platform_id
    attr_accessor :platform_user_id
    attr_accessor :resource_link_id

    def initialize(props)
      update(props)
    end
    def update(new_attrs)
      new_attrs.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
    end
  end

  describe HasPlatformInfo do
    let(:params) do
      {
        class_info_url: "class_info_url",
        context_id: "class_hash",
        platform_id: "test_portal",
        platform_user_id: "user-id-123",
        resource_link_id: "resource_link_id-321",
      }
    end
    let(:props) { {} }
    let(:my_run) { HasPlatformInfo.new(props) }
    describe "with no existing platform info" do
      it 'has nil attributes' do
        expect(my_run.class_info_url).to be_nil
        expect(my_run.context_id).to be_nil
        expect(my_run.platform_id).to be_nil
        expect(my_run.platform_user_id).to be_nil
        expect(my_run.resource_link_id).to be_nil
      end
      it "can be updated with it has no existing attributes" do
        my_run.update_platform_info(params)
        expect(my_run.class_info_url).to eql "class_info_url"
        expect(my_run.context_id).to eql "class_hash"
        expect(my_run.platform_id).to eql "test_portal"
        expect(my_run.platform_user_id).to eql "user-id-123"
        expect(my_run.resource_link_id).to eql "resource_link_id-321"
      end
    end
    describe "with existing platform info" do
      let(:props) do
        {
          class_info_url: "old_class_info",
          context_id: "old_class_hash",
          platform_id: "old_test_portal",
          platform_user_id: "old_user-id-123",
          resource_link_id: "old_resource_link_id-321",
        }
      end
      it 'has the attributes' do
        expect(my_run.class_info_url).to eql("old_class_info")
        expect(my_run.context_id).to eql("old_class_hash")
        expect(my_run.platform_id).to eql("old_test_portal")
        expect(my_run.platform_user_id).to eql("old_user-id-123")
        expect(my_run.resource_link_id).to eql("old_resource_link_id-321")
      end
      it "wont be updated with new values" do
        my_run.update_platform_info(params)
        expect(my_run.class_info_url).to eql("old_class_info")
        expect(my_run.context_id).to eql("old_class_hash")
        expect(my_run.platform_id).to eql("old_test_portal")
        expect(my_run.platform_user_id).to eql("old_user-id-123")
        expect(my_run.resource_link_id).to eql("old_resource_link_id-321")
      end
    end
  end

end
