require 'spec_helper'

describe MwInteractive do
  it_behaves_like "a base interactive", :mw_interactive

  let (:interactive_options) { {linked_interactive_id: 1} }
  let (:interactive) { FactoryGirl.create(:mw_interactive, interactive_options) }
  let (:page) { FactoryGirl.create(:page) }

  it 'has valid attributes' do
    interactive.valid?
  end

  it 'can to associate an interactive page' do

    page.add_interactive(interactive)

    interactive.reload
    page.reload

    expect(interactive.interactive_page).to eq(page)
  end

  describe '#to_hash' do
    it 'has useful values' do
      expected = {
        name: interactive.name,
        url: interactive.url,
        native_width: interactive.native_width,
        native_height: interactive.native_height,
        enable_learner_state: interactive.enable_learner_state,
        show_delete_data_button: interactive.show_delete_data_button,
        has_report_url: interactive.has_report_url,
        click_to_play: interactive.click_to_play,
        click_to_play_prompt: interactive.click_to_play_prompt,
        full_window: interactive.full_window,
        model_library_url: interactive.model_library_url,
        image_url: interactive.image_url,
        is_hidden: interactive.is_hidden,
        is_half_width: interactive.is_half_width,
        authored_state: interactive.authored_state,
        show_in_featured_question_report: interactive.show_in_featured_question_report,
        aspect_ratio_method: interactive.aspect_ratio_method,
        no_snapshots: interactive.no_snapshots,
        linked_interactive_item_id: interactive.linked_interactive_item_id,
        linked_interactives: [],
        report_item_url: interactive.report_item_url
      }
      hash = interactive.to_hash
      expect(hash).to eq(expected)
      expect(hash[:linked_interactive_id]).to be_nil
      expect(hash[:linked_interactive_type]).to be_nil
    end
  end

  describe '#to_authoring_hash' do
    it 'has useful values' do
      page.add_interactive(interactive)
      interactive.reload
      page.reload

      expected = interactive.to_hash
      expected[:id] = interactive.id
      expected[:linked_interactive_id] = interactive.linked_interactive_id
      expected[:linked_interactive_type] = interactive.linked_interactive_type
      expected[:aspect_ratio] = interactive.aspect_ratio
      expected[:interactive_item_id] = interactive.interactive_item_id
      expected[:linked_interactive_item_id] = interactive.linked_interactive_item_id
      expected[:linked_interactives] = interactive.linked_interactives_list
      expect(interactive.to_authoring_hash).to eq(expected)
    end
  end

  describe '#to_authoring_preview_hash' do
    it 'has useful values' do
      expected = interactive.to_authoring_hash
      expected[:linked_interactives] = interactive.linked_interactives_list
      expect(interactive.to_authoring_preview_hash).to eq(expected)
    end
  end

  describe '#duplicate' do
    it 'is a new instance of MwInteractive with values' do
      interactive.is_hidden = true
      expect(interactive.duplicate).to be_a_new(MwInteractive).with({
        name: interactive.name,
        url: interactive.url,
        native_width: interactive.native_width,
        native_height: interactive.native_height,
        click_to_play: interactive.click_to_play,
        full_window: interactive.full_window,
        model_library_url: interactive.model_library_url,
        image_url: interactive.image_url,
        is_hidden: interactive.is_hidden,
        is_half_width: interactive.is_half_width,
        authored_state: interactive.authored_state
      })
    end
  end

  # This approach is temporary, it is specific for ITSI style authoring.
  # It allows authors to select a special interactive, and then the labbook automatically becomes an
  # uploading labbook
  # If we keep the data modeling for this, then this code should be moved to the ITSI style authoring
  # javascript code.
  # Better yet would be to find another way to model and/or author this.
  describe 'labbook options' do
    let (:labbook) { FactoryGirl.create(:labbook, action_type: Embeddable::Labbook::SNAPSHOT_ACTION, custom_action_label: "custom action label") }
    let (:interactive) { FactoryGirl.create(:mw_interactive, labbook: labbook) }

    it 'remain the same if url changes to a non-upload only url' do
      stub_const('ENV', {'UPLOAD_ONLY_MODEL_URLS' => 'upload_url1|upload_url2'})
      interactive.url = 'not_an_upload_url'
      interactive.save
      expect(interactive.labbook.action_type).to eq(Embeddable::Labbook::SNAPSHOT_ACTION)
      expect(interactive.labbook.custom_action_label).to eq("custom action label")
    end

    describe 'change to upload options if url changes' do
      it 'to an upload only url' do
        stub_const('ENV', {'UPLOAD_ONLY_MODEL_URLS' => 'upload_url1|upload_url2'})
        interactive.url = 'upload_url2'
        interactive.save
        expect(interactive.labbook.action_type).to eq(Embeddable::Labbook::UPLOAD_ACTION)
        expect(interactive.labbook.custom_action_label).to eq("Take a Snapshot")
      end
      it 'to an upload only url with spaces in the environment variable' do
        stub_const('ENV', {'UPLOAD_ONLY_MODEL_URLS' => '   upload_url1  |  upload_url2 '})
        interactive.url = 'upload_url1'
        interactive.save
        expect(interactive.labbook.action_type).to eq(Embeddable::Labbook::UPLOAD_ACTION)
        expect(interactive.labbook.custom_action_label).to eq("Take a Snapshot")
      end
    end

    it 'revert from upload options if url changes from an upload only url' do
      stub_const('ENV', {'UPLOAD_ONLY_MODEL_URLS' => 'upload_url1|upload_url2'})
      interactive.url = 'upload_url1'
      interactive.save
      expect(interactive.labbook.action_type).to eq(Embeddable::Labbook::UPLOAD_ACTION)
      expect(interactive.labbook.custom_action_label).to eq("Take a Snapshot")
      interactive.url = 'not_an_upload_url'
      interactive.save
      expect(interactive.labbook.action_type).to eq(Embeddable::Labbook::SNAPSHOT_ACTION)
      expect(interactive.labbook.custom_action_label).to eq(nil)
    end
  end

  describe "aspect_ratio_method" do
    let (:ar_method) { MwInteractive::ASPECT_RATIO_DEFAULT_METHOD }
    let (:width)  { 800 }
    let (:height) { 400 }
    let (:interactive_options) do
      {
        aspect_ratio_method: ar_method,
        native_width: width,
        native_height: height
      }
    end

    describe "the default value" do
      it "Should be 'DEFAULT'" do
        expect(interactive.aspect_ratio_method).to eq(MwInteractive::ASPECT_RATIO_DEFAULT_METHOD)
        expect(interactive.aspect_ratio_method).to eq("DEFAULT")
      end
    end


    describe "with manually set values of width 800 and height 400" do
      let (:width)  { 800 }
      let (:height) { 400 }
      describe "With 'default' aspect_ratio_method selected" do
        let (:ar_method) { MwInteractive::ASPECT_RATIO_DEFAULT_METHOD }
        describe "aspect_ratio" do
          it 'should use the default value of 1.324' do
            expect(interactive.aspect_ratio).to be_within(0.01).of(1.32)
          end
        end
        describe "height" do
          it 'returns a calculated height from a supplied width, based on aspect ratio' do
            # (800 / 1.324) ~ 604
            expect(interactive.height(800)).to be_within(1).of(604)
          end
        end
      end

      describe "With 'manual' aspect_ratio_method selected" do
        let (:ar_method) { MwInteractive::ASPECT_RATIO_MANUAL_METHOD }
        describe "aspect_ratio" do
          it 'should use the calculated value of 800/400 == 2' do
            expect(interactive.aspect_ratio).to be_within(0.01).of(2)
          end
        end
        describe "height" do
          it 'returns a calculated height from a supplied width, based on aspect ratio' do
            # (1000 / 2) ~ 500
            expect(interactive.height(1000)).to be_within(0.01).of(500)
          end
        end
      end

      describe "With 'maximum' aspect_ratio_method selected" do
        let (:ar_method) { MwInteractive::ASPECT_RATIO_MAX_METHOD }
        let (:available_width)  { 500 }
        let (:available_height) { 100 }
        describe "aspect_ratio" do
          it 'should use the available width and height to calc 500/100 == 5' do
            expect(interactive.aspect_ratio(available_width, available_height))
              .to be_within(0.01).of(5)
          end
        end
        describe "height" do
          it 'returns a calculated height equal to available height' do
            # (500 / 5) ~ 100
            expect(interactive.height(available_width, available_height))
              .to be_within(0.01).of(available_height)
          end
        end
      end
    end

  end
end
