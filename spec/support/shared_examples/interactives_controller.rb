shared_examples "interactives controller" do
  # interactive_label is provided by main test file
  let (:activity) { FactoryGirl.create(:activity_with_page) }
  let (:page) { activity.pages.first }
  let (:int) { FactoryGirl.create(interactive_label, name: 'Test Interactive') }

  describe 'update' do
    # PJ 11/03/2020: Old comment said that "authorization is tested in spec/models/user_spec.rb"
    # But I don't really see how this would work. I think there's no authorization at this moment (or I miss something).
    it 'replaces the values of the interactive to match submitted values' do
      new_values_hash = { name: 'Edited name' }
      post :update, params: { id: int.id, page_id: page.id, interactive_label => new_values_hash }

      int.reload
      expect(int.name).to eq(new_values_hash[:name])
    end

    it 'returns to the edit page when there are no errors' do
      new_values_hash = { name: 'Edited name' }
      post :update, params: { id: int.id, page_id: page.id, interactive_label => new_values_hash }
      expect(response).to redirect_to(edit_activity_page_path(activity, page))
    end

    describe "when linked_interactives param is present" do
      describe "on a page with interactives" do
        let (:int2) { FactoryGirl.create(interactive_label, name: 'Test Interactive 2') }
        let (:int3) { FactoryGirl.create(interactive_label, name: 'Test Interactive 3') }

        def add_interactive_to_section(page, interactive, section)
          page.add_embeddable(interactive, nil, section)
          interactive.reload
        end
        
        before :each do
          add_interactive_to_section(page, int, InteractivePage::INTERACTIVE_BOX)
          add_interactive_to_section(page, int2, InteractivePage::HEADER_BLOCK)
          add_interactive_to_section(page, int3, nil) # nil is assessment block
          page.save!(validate: true)
          page.reload
        end

        it "allows a 1:1 link" do
          new_values_hash = { linked_interactives: {
            linkedInteractives: [
              {id: int2.interactive_item_id, label: "two"}
            ],
            linkedState: int3.interactive_item_id
          }.to_json
          }
          post :update, params: { id: int.id, page_id: page.id, interactive_label => new_values_hash }

          int.reload
          expect(LinkedPageItem.count).to eql(1)
          expect(int.linked_interactive).to eql(int3)
          expect(response).to redirect_to(edit_activity_page_path(activity, page))
        end

        it "allows a 1:N link" do
          new_values_hash = { linked_interactives: {
            linkedInteractives: [
              {id: int2.interactive_item_id, label: "two"},
              {id: int3.interactive_item_id, label: "three"}
            ],
            linkedState: int3.interactive_item_id
          }.to_json
          }
          post :update, params: { id: int.id, page_id: page.id, interactive_label => new_values_hash }

          int.reload
          expect(LinkedPageItem.count).to eql(2)
          expect(int.linked_interactive).to eql(int3)
          expect(response).to redirect_to(edit_activity_page_path(activity, page))
        end

        describe "when there are linked interactives already" do
          before(:each) do
            add_linked_interactive(int, int2, "one")
            add_linked_interactive(int, int3, "two")
            int.linked_interactive = int3
          end

          it "allows to clear the linked interactives list and linked state" do
            expect(LinkedPageItem.count).to eql(2)

            new_values_hash = { linked_interactives: {
              linkedInteractives: [],
              linkedState: nil
            }.to_json
            }
            post :update, params: { id: int.id, page_id: page.id, interactive_label => new_values_hash }

            int.reload
            expect(LinkedPageItem.count).to eql(0)
            expect(int.linked_interactive).to eql(nil)
            expect(response).to redirect_to(edit_activity_page_path(activity, page))
          end
        end
      end
    end
  end
end
