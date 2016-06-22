require 'spec_helper'

describe LaraSerializationHelper do
  let(:a_stubs)         { {id: 100} }
  let(:b_stubs)         { {id: 101} }
  let(:copy_a_stubs)    { {id: 200} }
  let(:copy_b_stubs)    { {id: 201} }
  let(:original_item_a) { mock_model(MwInteractive, a_stubs      )}
  let(:original_item_b) { mock_model(MwInteractive, b_stubs      )}
  let(:copy_of_item_a)  { mock_model(MwInteractive, copy_a_stubs )}
  let(:copy_of_item_b)  { mock_model(MwInteractive, copy_b_stubs )}
  let(:helper)          { LaraSerializationHelper.new }

  describe "#cache_item_copy(original_item, copy_of_item)" do
    let(:expected_key)  { helper.key original_item_a }
    it "should store our new item with a key for the original" do
      helper.cache_item_copy(original_item_a, copy_of_item_a)
      expect(helper.lookup_item(expected_key)).to eq copy_of_item_a
    end
  end

  describe "#lookup_new_item(original_item)" do
    describe "when two interactive copies are saved" do
      it "should return the correct copy for a given original" do
        helper.cache_item_copy(original_item_a, copy_of_item_a)
        helper.cache_item_copy(original_item_b, copy_of_item_b)
        expect(helper.lookup_new_item(original_item_a)).to eq copy_of_item_a
        expect(helper.lookup_new_item(original_item_b)).to eq copy_of_item_b
      end
    end
  end

  describe "#cache_item and #lookup_item" do
    let(:my_key)  { "I made this up" }
    let(:my_item) { original_item_a  }
    it "stores the item with a custom key, so we can fetch it later" do
      helper.cache_item(my_key,my_item)
      expect(helper.lookup_item(my_key)).to eq my_item
    end
  end

  describe "#wrap_export" do
    let(:export)          { {a:1, b:2} }
    let(:item_stubs)      { {id: 100 } }
    let(:interactive)     { mock_model(MwInteractive, item_stubs)       }
    let(:result)          { helper.wrap_export(interactive)             }
    let(:expected_key)    { helper.key interactive }

    describe "for an interactive" do
      it "should call export on our test-subject" do
        expect(interactive).to receive(:export).and_return(export)
        expect(result).to include(a:1, b:2)
      end
      it "should append `ref_id` and `type` tags the export data" do
        expect(interactive).to receive(:export).and_return(export)
        expect(result).to include(ref_id: expected_key, type:'MwInteractive')
      end
    end

    describe "for a Labbook embeddable" do
      let(:em_stubs)      { { interactive: interactive }              }
      let(:embeddable)    { mock_model(Embeddable::Labbook, em_stubs) }
      let(:expected_hash) { {interactive_ref_id: expected_key, type:'Embeddable::Labbook'} }
      let(:result)        { helper.wrap_export(embeddable)            }

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

  # def wrap_import(item_hash)
  describe "#wrap_import" do
    describe "importing an interactive" do
      let(:export_data)  do
        { type: "MwInteractive", ref_id: "100-MwInteractive" }
      end
      let(:result) { helper.wrap_import(export_data) }

      it "should add a cache entry for the interactive" do
        expect(result).to be_a MwInteractive
        expect(helper.lookup_item(export_data[:ref_id])).to eq result
      end
    end

    describe "import embeddable that references an interactive" do
      let(:export_data) do
        { type: "Embeddable::Labbook",  interactive_ref_id: "xyzzy" }
      end

      let(:interactive) { mock_model MwInteractive        }
      let(:result)      { helper.wrap_import(export_data) }

      before(:each) do
        helper.cache_item("xyzzy", interactive)
      end

      it "should find the referenced interactive in the cache" do
        expect(result).to be_a Embeddable::Labbook
        expect(result.interactive).to eq interactive
      end
    end
  end

end
