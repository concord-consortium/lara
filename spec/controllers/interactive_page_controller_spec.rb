require 'spec_helper'

describe InteractivePagesController do
  # TODO: This file is far too big, and contains a lot of view/request testing which should happen there and not here.

  render_views
  let(:project) { FactoryBot.create(:project) }
  let (:act) { FactoryBot.create(:public_activity, project: project ) }

  let (:page1) do
    page1 = FactoryBot.create(:page, lightweight_activity: act)
  end

  let (:page2) do
    page2 = FactoryBot.create(:page, name: "Page 2", lightweight_activity: act)
  end

  let (:page3) do
    page3 = FactoryBot.create(:page, name: "Page 3", lightweight_activity: act)
  end

  let (:user) { FactoryBot.create(:user) }
  let (:ar) { FactoryBot.create(:run, activity_id: act.id, user_id: nil) }

  let (:interactive) { FactoryBot.create(:mw_interactive) }
  let (:sequence) { FactoryBot.create(:sequence, lightweight_activities: [act]) }
  let (:sequence_run) { FactoryBot.create(:sequence_run, sequence_id: sequence.id, user_id: nil) }

  describe 'routing' do
    it 'recognizes and generates #show' do
      expect({get: "activities/1/pages/3"}).to route_to(controller: 'interactive_pages', action: 'show', id: "3", activity_id: "1")
    end
  end

  describe 'show' do

    it 'renders 404 when the activity does not exist' do
      begin
        get :show, params: { id: 34 }
      rescue ActiveRecord::RecordNotFound
      end
    end

    it_behaves_like "runnable resource not launchable by the portal", Run do
      let(:action) { :show }
      let(:resource_template) { 'interactive_pages/show' }
      let(:base_params) { {activity_id: act.id, id: page1.id } }
      let(:base_factory_params) { {activity_id: act.id} }
      let(:run_path_helper) { :page_with_run_path }
      let(:run_key_param_name) { :run_key }
      let(:run_variable_name) { :run }
    end

    it 'assigns a sequence if one is in the run' do
      ar.sequence = sequence
      ar.sequence_run = sequence_run
      ar.save
      get :show, params: { id: page1.id, run_key: ar.key }
      expect(assigns(:sequence)).to eq(sequence)
    end

    describe 'when it is part of a sequence' do
      let (:seq_run) { FactoryBot.create(:sequence_run, sequence_id: sequence.id, user_id: nil) }

      before(:each) do
        # Add the activity to the sequence
        act.sequences = [sequence]
        act.save
      end

      it_behaves_like "runnable resource not launchable by the portal", Run do
        let(:action) { :show }
        let(:resource_template) { 'interactive_pages/show' }
        let(:base_params) { {id: page1.id, activity_id: act.id, sequence_id: sequence.id} }
        let(:base_factory_params) { {activity_id: act.id, sequence_id: sequence.id,
          sequence_run: sequence_run} }
        let(:run_path_helper) { :sequence_page_with_run_path }
        let(:run_key_param_name) { :run_key }
        let(:run_variable_name) { :run }
      end
    end

    it 'renders the page if it exists' do

      # Add embeddables
      page1.add_interactive(interactive)

      # get the rendering
      get :show, params: { id: page1.id, run_key: ar.key }

      # verify the page is as expected
      expect(response.body).to match /<iframe/m

    end

    # --- Most of this should probably go to the view spec ---
    it 'lists pages with links to each' do
      # setup
      page1
      page2
      page3
      get :show, params: { id: act.pages.first.id, run_key: ar.key }

      expect(response.body).to match /<a[^>]*href="\/activities\/#{act.id}\/pages\/#{act.pages.first.id}\/#{ar.key}"[^>]*>[^<]*1[^<]*<\/a>/
      expect(response.body).to match /<a[^>]*href="\/activities\/#{act.id}\/pages\/#{act.pages[1].id}\/#{ar.key}"[^>]*>[^<]*2[^<]*<\/a>/
      expect(response.body).to match /<a[^>]*href="\/activities\/#{act.id}\/pages\/#{act.pages[2].id}\/#{ar.key}"[^>]*>[^<]*3[^<]*<\/a>/
    end

    it 'only renders the forward navigation link on the first page' do
      page1
      page2
      get :show, params: { id: act.pages.first.id, run_key: ar.key }

      expect(response.body).to match /<a class='pagination-link prev disabled'>/
      expect(response.body).to match /<a class='pagination-link'/
    end

    it 'renders both the forward and back navigation links if it is a middle page' do
      page1
      page2
      page3
      get :show, params: { id: act.pages[1].id, run_key: ar.key }

      expect(response.body).to match /<a class='pagination-link prev' href='\/activities\/#{act.id}\/pages\/#{act.pages[0].id}\/#{ar.key}'>/
      expect(response.body).to match /<a class='next forward_nav' href='\/activities\/#{act.id}\/pages\/#{act.pages[2].id}\/#{ar.key}'>/
    end

    it 'only renders the back navigation links on the last page' do
      page1
      page2
      page3
      get :show, params: { id: act.pages.last.id, run_key: ar.key }

      expect(response.body).to match /<a class='pagination-link prev' href='\/activities\/#{act.id}\/pages\/#{act.pages[act.pages.length-2].id}\/#{ar.key}'>/
      expect(response.body).to match /<a class='pagination-link next forward_nav disabled'>/
    end

    it 'indicates the active page with a DOM class attribute' do
      page1
      page2
      page3
      get :show, params: { id: act.pages.first.id, run_key: ar.key }

      # This regex checks for an 'a' tag with the classes 'pagination-link' and 'selected' classes, and should match
      # regardless of the attributes order in the tag. This replaces a regex that assumed the `class` attribute would
      # always appear after the `href` which doesn't appear to be the case after we upgraded to Rails 4 from Rails 3.
      # There is probably a more robust way to approach the problem, but I believe we're checking dead code here.
      expect(response.body).to match(/<a[^>]*class="[^"]*\bpagination-link\b[^"]*\bselected\b[^"]*"[^>]*href="\/activities\/#{act.id}\/pages\/#{act.pages.first.id}\/#{ar.key}">1<\/a>/)
    end

    it 'renders pagination links if it is the only page' do
      page1
      get :show, params: { id: page1.id, run_key: ar.key }

      expect(response.body).not_to match /<a class='prev'>/
      expect(response.body).not_to match /<a class='next'>/
    end

    it 'shows related content on the last page' do
      page1
      get :show, params: { id: page1.id, run_key: ar.key }

      expect(response.body).to match /<div class='related-mod'>/
    end

    it 'does not show related content on pages other than the last page' do
      page1
      page2
      get :show, params: { id: act.pages.first.id, run_key: ar.key }

      expect(response.body).not_to match /<div class='related-mod'>/
    end

    it 'calls LARA.addSidebar content on pages which have authored sidebar' do
      get :show, params: { id: page1.id, run_key: ar.key }
      # Note that page factory creates a page with sidebar by default.
      expect(response.body).to match /LARA\.addSidebar\({/
      page2.show_sidebar = false
      page2.save
      get :show, params: { id: page2.id, run_key: ar.key }
      expect(response.body).not_to match /LARA\.addSidebar\({/
    end
    # --- Ends section which should go to view spec ---
  end

  context 'when the current user is an author' do
    before(:each) do
      @user ||= FactoryBot.create(:admin)
      sign_in @user
    end

    describe 'preview' do
      it 'clears answers from the run' do
        page1
        expect(ar).to receive(:clear_answers)
        expect(Run).to receive(:lookup).and_return(ar)
        get :preview, params: { id: page1.id }
      end

      it 'renders show' do
        get :preview, params: { id: page1.id }
        expect(response).to render_template('interactive_pages/show')
      end
    end

    describe 'new' do
      it 'creates a new page and redirects to its edit page' do
        get :new, params: { activity_id: act.id }

        expect(response).to redirect_to(edit_activity_page_path(act.id, assigns(:page)))
      end
    end

    describe 'create' do
      it 'adds an InteractivePage to the current LightweightActivity' do
        activity_page_count = act.pages.length

        post :create, params: { activity_id: act.id }

        act.reload
        expect(act.pages.length).to eq(activity_page_count + 1)
        expect(act.changed_by).to eq(@user)
      end

    end

    describe 'edit' do
      context 'when editing an existing page' do
        it 'assigns variables' do
          get :edit, params: { activity_id: act.id, id: page1.id }
          expect(assigns(:page)).to eq(page1)
          expect(assigns(:activity)).to eq(act)
          expect(assigns(:all_pages)).not_to be_nil
        end
      end
    end

    describe 'update' do
      it 'updates the specified Page with provided values' do
        post :update, params: { _method: 'put', activity_id: act.id, id: page1.id, interactive_page: { sidebar: 'This page now has sidebar text.' } }

        page1.reload
        expect(page1.sidebar).to eq('This page now has sidebar text.')
        act.reload
        expect(act.changed_by).to eq(@user)
      end

      it 'redirects to the edit page with a message confirming success' do
        post :update, params: { _method: 'put', activity_id: act.id, id: page1.id, interactive_page: { sidebar: 'This page now has sidebar text.' } }

        expect(flash[:notice]).to eq("Page #{page1.name} was updated.")
        expect(response).to redirect_to(edit_activity_page_path(act, page1))
      end

      it 'redirects to the edit page with a message if there is an error' do
        allow_any_instance_of(InteractivePage).to receive(:save).and_return(false)
        post :update, params: { _method: 'put', activity_id: act.id, id: page1.id, interactive_page: { sidebar: 'This page now has sidebar text.' } }

        expect(flash[:warning]).to eq("There was a problem updating Page #{page1.name}.")
        expect(response).to redirect_to(edit_activity_page_path(act, page1))
      end

      context 'when the request is XHR' do
        it 'returns the new text of the first value' do
          put :update, params: { activity_id: act.id, id: page1.id, interactive_page: { sidebar: 'This page now has sidebar text.' } }, xhr: true

          expect(response.body).to match /This page now has sidebar text./
        end

        it 'returns the old text if the update fails' do
          allow_any_instance_of(InteractivePage).to receive(:update).and_return(false)
          old_name = page1.name
          put :update, params: { activity_id: act.id, id: page1.id, interactive_page: { name: 'This new name will fail.' } }, xhr: true

          expect(response.body).to match /#{old_name}/
        end
      end
    end

    describe 'destroy' do
      it 'removes the page from the database and redirects to the activity edit page with a message' do
        page1
        page2
        page_count = act.pages.length

        post :destroy, params: { _method: 'delete', id: page1.id }

        act.reload

        expect(act.pages.length).to eq(page_count - 1)
        expect(flash[:notice]).to eq("Page #{page1.name} was deleted.")
        expect(act.changed_by).to eq(@user)
        begin
          InteractivePage.find(page1.id)
          throw "Should not have been able to find this page"
        rescue ActiveRecord::RecordNotFound
        end

        page2.reload
        expect(page2.position).to eq(1)
      end

      it 'does not route with no ID' do
        expect {post :destroy, params: { _method: 'delete' }}.to raise_error(ActionController::UrlGenerationError)
      end
    end

    describe 'reorder_embeddables' do
      it 'accepts a list of embeddables in order and adjusts position values to match' do
        # Create one MultipleChoice embeddable, with choices
        mc1 = FactoryBot.create(:mc_with_choices)

        # Create another MultipleChoice embeddable, with choices
        mc2 = FactoryBot.create(:mc_with_choices)

        # Add the two embeddables created above to the page. The order they are added is the starting order: first on top, last on the bottom.
        page1.add_embeddable(mc1, 1)
        page1.add_embeddable(mc2, 5)

        # Send a reorder request with params to reverse the order
        get :reorder_embeddables, params: { id: page1.id, activity_id: act.id, embeddable: [ "#{mc2.id}.#{mc2.class.to_s}", "#{mc1.id}.#{mc1.class.to_s}" ] }, xhr: true

        page1.reload
        expect(page1.embeddables.first).to eq(mc2)
        expect(page1.embeddables.last).to eq(mc1)
        act.reload
        expect(act.changed_by).to eq(@user)
      end
    end

    describe 'add_embeddable' do
      it 'creates an arbitrary embeddable and adds it to the page' do
        mc_count = Embeddable::MultipleChoice.count()
        embeddable_count = page1.embeddables.length
        post :add_embeddable, params: { activity_id: act.id, id: page1.id, embeddable_type: 'Embeddable::MultipleChoice' }

        page1.reload

        expect(page1.embeddables.count).to eq(embeddable_count + 1)
        expect(Embeddable::MultipleChoice.count()).to eq(mc_count + 1)
      end

      it 'raises an error on invalid embeddable_type' do
        begin
          post :add_embeddable, params: { activity_id: act.id, id: page1.id, embeddable_type: 'Embeddable::Bogus' }
          raise 'Should not have been able to post a bogus embeddable_type'
        rescue ArgumentError
        end
      end
    end

    describe 'add_embeddable used with Interactive' do
      it 'creates an arbitrary interactive and adds it to the page' do
        images_count = ImageInteractive.count()
        interactives_count = page1.interactives.length
        post :add_embeddable, params: { activity_id: act.id, id: page1.id, embeddable_type: 'ImageInteractive' }
        page1.reload
        expect(page1.interactives.count).to eq(interactives_count + 1)
        expect(ImageInteractive.count()).to eq(images_count + 1)
      end
    end

    it 'add_embeddable redirects to the edit page' do
      embeddable_types = {
        Embeddable::MultipleChoice => :edit_mc,
        Embeddable::EmbeddablePlugin => :edit_embeddable_plugin,
        MwInteractive => :edit_mw_int,
        VideoInteractive => :edit_video
      }
      embeddable_types.each do |clazz, edit_slug|
        post :add_embeddable, params: { activity_id: act.id, id: page1.id, embeddable_type: clazz.name }
        act.reload
        expect(act.changed_by).to eq(@user)
        id = clazz.last.id
        params = {}
        params[edit_slug] = id
        expect(response).to redirect_to(edit_activity_page_path(act.id, page1.id, params))
      end
    end

    describe 'remove_page_item' do
      it 'removes the identified embeddable from the page' do
        embeddable = FactoryBot.create(:multiple_choice)
        page1.add_embeddable(embeddable)
        page1.reload
        embed_count = page1.embeddables.length
        post :remove_page_item, params: { page_item_id: embeddable.p_item.id }

        page1.reload
        expect(page1.embeddables.length).to eq(embed_count - 1)
        !page1.embeddables.include?(embeddable)
      end

      it 'redirects to the edit page' do
        embeddable = FactoryBot.create(:multiple_choice)
        page1.add_embeddable(embeddable)
        post :remove_page_item, params: { page_item_id: embeddable.p_item.id }

        act.reload
        expect(act.changed_by).to eq(@user)
        expect(response).to redirect_to(edit_activity_page_path(act.id, page1.id))
      end
    end
  end
end
