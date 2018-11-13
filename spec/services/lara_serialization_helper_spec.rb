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
  end

end
