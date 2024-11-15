require 'spec_helper'

describe "rendering labbook answer partial" do
  def data_attribute(name,value)
    "[data-#{name}='#{value}']"
  end

  let(:run)             { Run.new }
  let(:interactive_id)  { 7 }
  let(:interactive)     { stub_model(ImageInteractive, id: 7 ) }
  let(:labbook)         { stub_model(Embeddable::Labbook, interactive: interactive) }
  let(:labbook_answer)  { Embeddable::LabbookAnswer.create(question: labbook, run: run) }

  it "displays the partial for a labbook" do
    render partial: "embeddable/labbook_answers/lightweight", locals: {embeddable: labbook_answer}
    expect(rendered).to have_css('.question-bd.labbook')
  end

  it "includes data-binding attributes" do
    render partial: "embeddable/labbook_answers/lightweight", locals: {embeddable: labbook_answer}
    expected_css = data_attribute('interactive-id', interactive_id)
    expect(rendered).to have_css(expected_css)
  end
end
