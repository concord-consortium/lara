require 'spec_helper'

describe "WithClassInfo" do

  class HasClassInfo
    include WithClassInfo
    attr_accessor :class_info_url
    attr_accessor :class_hash

    def initialize(props)
      update_attributes(props)
    end
    def update_attributes(new_attrs)
      self.class_info_url = new_attrs[:class_info_url]
      self.class_hash     = new_attrs[:class_hash]
    end
  end

  describe HasClassInfo do
    let(:params){ {'class_info_url' => "class_info_url", 'class_hash' => "class_hash"} }
    let(:props) { {} }
    let(:my_run) { HasClassInfo.new(props) }
    describe "with no existing class info" do
      it 'has nil attributes' do
        expect(my_run.class_info_url).to be_nil
        expect(my_run.class_hash).to be_nil
      end
      it "can be updated with it has no existing attributes" do
        my_run.update_class_info(params)
        expect(my_run.class_info_url).to eql "class_info_url"
        expect(my_run.class_hash).to eql "class_hash"
      end
    end
    describe "with existing class info" do
      let(:props){ {class_info_url: "old_class_info", class_hash: "old_class_hash"} }
      it 'has the attributes' do
        expect(my_run.class_info_url).to eql("old_class_info")
        expect(my_run.class_hash).to eql("old_class_hash")
      end
      it "wont be updated with new values" do
        my_run.update_class_info(params)
        expect(my_run.class_info_url).to eql "old_class_info"
        expect(my_run.class_hash).to eql "old_class_hash"
      end
    end
  end

end
