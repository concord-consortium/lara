require 'factory_girl'

shared_examples 'an embeddable controller' do |model_factory|

  describe "#update" do
    let(:sequence)  { FactoryGirl.create(:sequence) }
    let(:activity)  { FactoryGirl.create(:activity) }
    let(:page)      { FactoryGirl.create(:interactive_page, name: "page 1", position: 0) }
    let(:model)     { FactoryGirl.create(model_factory, name:"xzzy") }

    before(:each) {
      page.add_embeddable(model)
      activity.pages << page
      sequence.activities << activity
    }

    subject {
      request.env['HTTP_REFERER'] = 'http://example.com'

      patch :update, id: model.id, model.class.name_as_param.to_s => {name: "updated name"}
    }

    it "causes the activity to be republished to the portal" do
      expect_any_instance_of(LightweightActivity).to receive(:queue_auto_publish_to_portal)
      subject
    end

    it "causes the activity to be republished to the report service" do
      expect_any_instance_of(LightweightActivity).to receive(:queue_publish_to_report_service)
      subject
    end

    it "causes the sequence to be republished to the portal" do
      expect_any_instance_of(Sequence).to receive(:queue_auto_publish_to_portal)
      subject
    end

    it "causes the sequence to be republished to the report service" do
      expect_any_instance_of(Sequence).to receive(:queue_publish_to_report_service)
      subject
    end
  end

end
