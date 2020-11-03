require 'spec_helper'

describe ManagedInteractivesController do
  render_views
  let (:activity) { FactoryGirl.create(:activity_with_page) }
  let (:page) { activity.pages.first }
  let (:int) { FactoryGirl.create(:managed_interactive, :name => 'Test Managed Interactive', :url_fragment => '/interactive') }
  let (:int2) { FactoryGirl.create(:managed_interactive, :name => 'Test Managed Interactive 2', :url_fragment => '/interactive2') }
  let (:int3) { FactoryGirl.create(:managed_interactive, :name => 'Test Managed Interactive 3', :url_fragment => '/interactive3') }

  def add_interactive_to_section(page, interactive, section)
    page.add_embeddable(interactive, nil, section)
    interactive.reload
  end

  describe 'show' do
    it 'is not routable' do
      begin
        get :show, :id => 'foo'
        throw 'should not have been able to route to show'
      rescue
      end
    end
  end

  context 'when the logged-in user is an author' do
    # Authorization is tested in spec/models/user_spec.rb
    # In the UI a Managed interactive is called a Library Interactive
    context 'when editing an existing Managed Interactive' do
      describe 'edit' do
        it 'shows a form with values of the Managed Interactive filled in' do
          get :edit, :id => int.id
          expect(response).to be_successful
        end

        it 'responds to js-format requests with JSON' do
          page
          get :edit, :id => int.id, :page_id => page.id, :format => 'js'

          expect(response.headers['Content-Type']).to match /text\/json/
          value_hash = JSON.parse(response.body)
          expect(value_hash['html']).to match %r[<form[^>]+action=\"/pages\/#{page.id}\/managed_interactives\/#{int.id}\"[^<]+method=\"post]
        end
      end

      describe 'update' do
        it 'replaces the values of the Managed Interactive to match submitted values' do
          new_values_hash = { :name => 'Edited name', :url_fragment => '/foo' }
          post :update, :id => int.id, :page_id => page.id, :managed_interactive => new_values_hash

          managed_int = ManagedInteractive.find(int.id)
          expect(managed_int.name).to eq(new_values_hash[:name])
          expect(managed_int.url_fragment).to eq(new_values_hash[:url_fragment])
        end

        it 'returns to the edit page when there are no errors' do
          new_values_hash = { :name => 'Edited name', :url_fragment => '/foo' }
          post :update, :id => int.id, :page_id => page.id, :managed_interactive => new_values_hash
          expect(response).to redirect_to(edit_activity_page_path(activity, page))
        end

        it 'raises an error when update fails' do
          expect {
            new_values_hash = { :custom_native_width => 'Ha!' }
            post :update, :id => int.id, :page_id => page.id, :managed_interactive => new_values_hash
          }.to raise_error ActiveRecord::RecordInvalid
        end

        describe "when linked_interactives param is present" do
          describe "on a page with interactives" do
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
              post :update, :id => int.id, :page_id => page.id, :managed_interactive => new_values_hash

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
              post :update, :id => int.id, :page_id => page.id, :managed_interactive => new_values_hash

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
                post :update, :id => int.id, :page_id => page.id, :managed_interactive => new_values_hash

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
  end
end
