require 'spec_helper'


describe "interactive_pages/_list_embeddables.html.haml" do
  let(:run)             { Run.new }
  let(:interactive_id)  { 7 }
  let(:interactive)     { stub_model(ImageInteractive, id: 7 ) }
  let(:labbook)         { stub_model(Embeddable::Labbook) }
  let(:labbook_answer)  { Embeddable::LabbookAnswer.create(question: labbook, run: run) }
  let(:embeddables)     { [labbook_answer] }

  describe "Displaying labbook answers" do
    describe "when the labbook doesn't have an interactive" do
      it "should not be shown" do
        expect(rendered).not_to have_css('.question-bd.labbook')
      end
    end
    describe "when the labbook has an interactive" do
      let(:labbook)         { stub_model(Embeddable::Labbook, interactive: interactive) }
      it "should show the labbook answer" do
        render partial: "interactive_pages/list_embeddables", locals: {embeddables: embeddables}
        expect(rendered).to have_css('.question-bd.labbook')
      end
    end
  end
end


# /Users/npaessel/lab/cc/lara/app/views/interactive_pages/_list_embeddables.html.haml
