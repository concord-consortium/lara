require 'spec_helper'

describe CRater::ArgumentationBlocksController do
  let(:user) { FactoryGirl.create(:author) }
  let(:act)  { FactoryGirl.create(:activity_with_page, user: user) }
  let(:page) { act.pages.first }
  let(:prev_page) { 'http://prev.page.com' }

  before(:each) do
    sign_in user
    @request.env['HTTP_REFERER'] = prev_page
  end

  describe '#create_embeddables' do
    it 'should create argumentation block embeddables' do
      post :create_embeddables, page_id: page.id
      allow_any_instance_of(InteractivePage).to receive(:show_arg_block).and_return(true)
      page.show_arg_block
      expect(page.embeddables.length).to eql(4)
      expect(response).to redirect_to(prev_page)
    end
  end

  describe '#remove_embeddables' do
    let (:open_response)          { FactoryGirl.create(:open_response) }
    let (:arg_block_open_response) { FactoryGirl.create(:open_response) }
    before(:each) do
      page.add_embeddable(open_response)
      page.add_embeddable(arg_block_open_response, nil, CRater::ARG_SECTION_NAME)
    end
    it 'should remove *only* argumentation block embeddables' do
      post :remove_embeddables, page_id: page.id
      page.reload
      expect(page.embeddables.length).to eql(1)
      expect(page.embeddables).to include open_response
      expect(page.embeddables).not_to include arg_block_open_response
      expect(response).to redirect_to(prev_page)
    end
  end

  describe "#report" do
    include_context "activity with arg block submissions"

    let(:params) do
      {'arg_block_buckets' =>
        JSON.generate({
          'columns' => ['permission_forms', 'teachers_name', 'school_name', 'class_name', 'class_id',
                        'student_id', 'remote_endpoint'],
          'rows' => [['perm1', 'Teacher 1', 'School 1', 'Class 1', 1, 2, ['http://remote.endpoint']]]
       })
      }
    end

    context 'when user is not an admin' do
      it 'does not work' do
        post :report, params
        expect(response.status).to eql(403)
      end
    end

    context 'when user is an admin' do
      let(:user) { FactoryGirl.create(:admin) }
      it 'returns Excel spreadsheet' do
        post :report, params

        expect(response.status).to eql(200)

        data = StringIO.new(response.body)
        book = Spreadsheet.open data
        sheet = book.worksheet(0)

        expect(sheet.rows.count).to eql(2) # headers + data
        # Headers.
        expect(sheet.row(0).to_a).to eql(['Permission Form(s)', 'Teacher Name', 'School Name', 'Class Name', 'Class ID',
          'Student ID', 'Submission Date & Time', 'Activity Name', 'Activity ID', 'Page Name', 'Page ID',
          'Question ID (1)', 'Prompt (1)', 'Answer (1)', 'Score (1)', 'Feedback (1)',
          'Question ID (2)', 'Prompt (2)', 'Answer (2)', 'Score (2)', 'Feedback (2)',
          'Question ID (3)', 'Prompt (3)', 'Answer (3)', 'Score (3)', 'Feedback (3)',
          'Question ID (4)', 'Prompt (4)', 'Answer (4)', 'Score (4)', 'Feedback (4)',
          'Usefulness Score'])
        expect(sheet.row(0).to_a.count).to eql(sheet.row(1).to_a.count)
        # First set of values (provided as params).
        expect(sheet.row(1).to_a[0..5]).to eql(['perm1', 'Teacher 1', 'School 1', 'Class 1', 1, 2])
        # DateTime comparison.
        expect(sheet.row(1)[6].to_i).to eql(@submission.created_at.to_i)
        # Compare rest of the data.
        expect(sheet.row(1).to_a[7..-1]).to eql([act.name, act.id, page.name, page.id,
          @q1.id, @q1.prompt, @f1.answer_text, @f1.score, @f1.feedback_text,
          @q2.id, @q2.prompt, @f2.answer_text, @f2.score, @f2.feedback_text,
          @q3.id, @q3.prompt, @f3.answer_text, @f3.score, @f3.feedback_text,
          @q4.id, @q4.prompt, @f4.answer_text, @f4.score, @f4.feedback_text,
          @submission.usefulness_score])
      end
    end
  end
end
