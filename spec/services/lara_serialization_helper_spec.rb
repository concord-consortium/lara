require 'spec_helper'

describe LaraSerializationHelper do
  let(:helper) { LaraSerializationHelper.new }

  describe "#export" do
    let(:export)          { {a:1, b:2} }
    let(:item_stubs)      { {id: 100 } }
    let(:interactive)     { mock_model(MwInteractive, item_stubs)       }
    let(:result)          { helper.export(interactive)             }
    let(:expected_key)    { helper.key interactive }

    describe "for an interactive" do
      it "should call export on our test-subject" do
        expect(interactive).to receive(:export).and_return(export)
        expect(result).to include(a:1, b:2)
      end
      it "should append `ref_id` and `type` tags the export data" do
        expect(interactive).to receive(:export).and_return(export)
        expect(result).to include(ref_id: expected_key, type: 'MwInteractive')
      end
    end

    describe "for a Labbook embeddable" do
      let(:em_stubs)      { { interactive: interactive }              }
      let(:embeddable)    { mock_model(Embeddable::Labbook, em_stubs) }
      let(:expected_hash) { {interactive_ref_id: expected_key, type:'Embeddable::Labbook'} }
      let(:result)        { helper.export(embeddable)            }

      it "should call export on our test-subject" do
        expect(embeddable).to receive(:export).and_return(export)
        expect(result).to include(a:1, b:2)
      end
      it "should append `interactive_ref_id` and `type` tags the export data" do
        expect(embeddable).to receive(:export).and_return(export)
        expect(result).to include(expected_hash)
      end

      context "when the Labook has no interactive" do
        let(:embeddable)    { mock_model(Embeddable::Labbook, interactive: nil) }
        let(:expected_hash) { {interactive_ref_id: expected_key, type:'Embeddable::Labbook'} }

        it "should not append `interactive_ref_id`" do
          expect(embeddable).to receive(:export).and_return(export)
          expect(result).not_to include(:interactive_ref_id)
        end
      end
    end
  end

  describe "#export with linked interactives" do
    let(:interactive1)  { FactoryBot.create(:mw_interactive) }
    let(:interactive2)  { FactoryBot.create(:mw_interactive) }
    let(:interactive3)  { FactoryBot.create(:mw_interactive) }
    let(:interactive4)  { FactoryBot.create(:mw_interactive) }
    let(:page)          { FactoryBot.create(:page) }
    let(:expected_key)  { helper.key interactive1 }
    let(:expected_type) { 'MwInteractive' }
    let(:result)        { helper.export(interactive1) }

    before :each do
      page.add_interactive(interactive1)
      page.add_interactive(interactive2)
      page.add_interactive(interactive3)
      page.add_interactive(interactive4)
      interactive1.reload
      interactive2.reload
      interactive3.reload
      interactive4.reload
      page.reload
    end

    it "should append linked_interactives" do
      add_linked_interactive(interactive1, interactive2, "one")
      add_linked_interactive(interactive1, interactive3, "two")
      add_linked_interactive(interactive4, interactive1, "three")

      expect(result).to include({
        ref_id: expected_key,
        type: expected_type,
        linked_interactives: [
          {label: "one", ref_id: helper.key(interactive2)},
          {label: "two", ref_id: helper.key(interactive3)},
        ]
      })
    end
  end

  describe "#export with data source interactive" do
    let(:interactive1)  { FactoryBot.create(:mw_interactive) }
    let(:interactive2)  { FactoryBot.create(:mw_interactive, data_source_interactive: interactive1) }
    let(:page)          { FactoryBot.create(:page) }
    let(:expected_type) { 'MwInteractive' }

    it "should not export interactive1 with a data source interactive" do
      result = helper.export(interactive1)
      expect(result).to include({
        ref_id: helper.key(interactive1),
        type: expected_type,
      })
      expect(result).not_to have_key(:data_source_interactive)
    end

    it "should export interactive2 with a data source interactive" do
      result = helper.export(interactive2)
      expect(result).to include({
        ref_id: helper.key(interactive2),
        type: expected_type,
        data_source_interactive: helper.export(interactive1)
      })
      expect(result).to have_key(:data_source_interactive)
    end
  end

  describe "#import" do
    describe "importing an interactive" do
      let(:export_data) do
        { type: "MwInteractive", ref_id: "100-MwInteractive" }
      end
      let(:result) { helper.import(export_data) }

      it "should add a cache entry for the interactive and return the same item in subsequent import calls" do
        expect(result).to be_a MwInteractive
        expect(helper.import(export_data)).to eq result
      end
    end

    describe "import embeddable that references an interactive" do
      let(:export_data) do
        { type: "Embeddable::Labbook", interactive_ref_id: "100-MwInteractive" }
      end
      let(:interactive_export_data) do
        { type: "MwInteractive", ref_id: "100-MwInteractive" }
      end
      let(:interactive) { helper.import(interactive_export_data) }
      let(:result) do
        helper.import(export_data)
        helper.set_references(export_data)
      end

      before(:each) do
        # trigger import of the interactive
        interactive
      end

      it "should find the referenced interactive in the cache" do
        expect(result).to be_a Embeddable::Labbook
        expect(result.interactive).to eq interactive
      end
    end

    describe "import page with interactives linked to other interactives" do
      let(:export_data) do
        {
          type: "InteractivePage",
          ref_id: "100-InteractivePage",
          sections: [
            {
            "title": "interactive_box",
            "is_hidden": false,
            "layout": "full-width",
            "secondary_column_collapsible": false,
            "secondary_column_display_mode": "stacked",
            embeddables: [
              {
                type: "MwInteractive",
                ref_id: "100-MwInteractive",
                column: "primary",
                position: 1,
                linked_interactives: [
                  {
                    ref_id: "101-ManagedInteractive",
                    label: "one"
                  },
                  {
                    ref_id: "102-MwInteractive",
                    label: "two"
                  }
                ]
              },
              {
                type: "ManagedInteractive",
                ref_id: "101-ManagedInteractive",
                column: "primary",
                position: 2,
                linked_interactives: []
              },
              {
                type: "MwInteractive",
                ref_id: "102-MwInteractive",
                column: "primary",
                position: 3,
                linked_interactives: []
              },
              {
                type: "ManagedInteractive",
                ref_id: "103-ManagedInteractive",
                column: "primary",
                position: 4,
                linked_interactives: [
                  {
                    ref_id: "100-MwInteractive",
                    label: "three"
                  }
                ]
              }
            ]
          }]
        }
      end
      let(:result) do
        helper.import(export_data)
        helper.set_references(export_data)
      end

      it "should find the referenced linked interactives in the cache" do
        expect(result).to be_a InteractivePage
        expect(result.embeddables.length).to be 4

        interactive1, interactive2, interactive3, interactive4 = result.embeddables

        expect(interactive1).to be_a MwInteractive
        expect(interactive2).to be_a ManagedInteractive
        expect(interactive3).to be_a MwInteractive
        expect(interactive4).to be_a ManagedInteractive

        interactive1_linked_items = interactive1.primary_linked_items
        expect(interactive1_linked_items.length).to be 2
        expect(interactive1_linked_items[0].secondary.embeddable).to eq interactive2
        expect(interactive1_linked_items[1].secondary.embeddable).to eq interactive3
        expect(interactive1_linked_items[0].label).to eq "one"
        expect(interactive1_linked_items[1].label).to eq "two"

        expect(interactive2.page_item.primary_linked_items.length).to be 0
        expect(interactive3.page_item.primary_linked_items.length).to be 0

        interactive4_linked_items = interactive4.primary_linked_items
        expect(interactive4.page_item.primary_linked_items.length).to be 1
        expect(interactive4_linked_items[0].secondary.embeddable).to eq interactive1
        expect(interactive4_linked_items[0].label).to eq "three"
      end
    end

    describe "import interactive with data source interactive" do
      let(:export_data) do
        {
          type: "InteractivePage",
          ref_id: "100-InteractivePage",
          sections: [
            {
            "title": "interactive_box",
            "is_hidden": false,
            "layout": "full-width",
            "secondary_column_collapsible": false,
            "secondary_column_display_mode": "stacked",
            embeddables: [
              {
                type: "MwInteractive",
                ref_id: "100-MwInteractive",
                column: "primary",
                position: 1,
                linked_interactives: [],
              },
              {
                type: "ManagedInteractive",
                ref_id: "101-ManagedInteractive",
                column: "primary",
                position: 2,
                linked_interactives: [],
                data_source_interactive: {
                  type: "MwInteractive",
                  ref_id: "100-MwInteractive",
                  column: "primary",
                  position: 1,
                  linked_interactives: [],
                }
              }
            ]
          }]
        }
      end
      let(:result) do
        helper.import(export_data)
        helper.set_references(export_data)
      end

      it "should find the referenced data source interactive in the cache" do
        expect(result).to be_a InteractivePage
        expect(result.embeddables.length).to be 2

        interactive1, interactive2 = result.embeddables

        expect(interactive1).to be_a MwInteractive
        expect(interactive2).to be_a ManagedInteractive

        expect(interactive2.data_source_interactive).to eq interactive1
      end
    end
  end
end
