require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::MultipleChoice do
  it_behaves_like "a question"

  let (:multichoice) do
    mc = FactoryGirl.create(:multiple_choice)
    mc.create_default_choices
    mc.reload
    mc
  end

  let (:page) do
    p = FactoryGirl.create(:interactive_page)
    p.add_embeddable(multichoice)
    p.reload
    p
  end

  let(:first_mc_choice_id) { multichoice.choices.first.id }

  describe "a newly created MutipleChoiceQuestion" do
    it "belongs to a page" do
      expect(page.embeddables).to include(multichoice)
    end

    it "has three initial default answers" do
      expect(multichoice.choices.size).to eq(3)
    end

    # it "has a self-generated storage key" do
    #   multichoice.storage_key.should_not be_nil
    # end
  end

  describe "adding a new choice" do
    let (:choice) { multichoice.add_choice("my choice") }

    it "should have the new choice" do
      expect(multichoice.choices).to include(choice)
    end

    it "should update its choices when saved" do
      choice.choice = "fooo"
      choice.save
      multichoice.reload
      expect(multichoice.choices[3].choice).to eq("fooo")
    end
  end

  describe '#parse_choices' do
    it 'should return an empty array for a blank input' do
      expect(multichoice.parse_choices('')).to eq([])
    end

    it 'should return an array with one MultipleChoiceChoice when passed an integer' do
      choice_key = multichoice.choices.first.id.to_s
      expect(multichoice.parse_choices(choice_key)).to eq([multichoice.choices.first])
      expect(multichoice.parse_choices(choice_key).first).to be_a_kind_of Embeddable::MultipleChoiceChoice
    end

    it 'should return an array of several MultipleChoiceChoices when passed a list of comma-separated integers' do
      choice_key = multichoice.choices.map{ |c| c.id }.join(',')
      expect(multichoice.parse_choices(choice_key).length).to eq(multichoice.choices.length)
      expect(multichoice.parse_choices(choice_key).first).to be_a_kind_of Embeddable::MultipleChoiceChoice
    end
  end

  describe '#check' do
    describe 'when the MultipleChoice is not multi-answer' do
      it 'should return a MultipleChoiceChoice instance' do
        expect(multichoice.check("#{first_mc_choice_id}")).to be_a_kind_of Embeddable::MultipleChoiceChoice
      end
    end

    describe 'when the MultipleChoiceChoice is multi-answer' do
      let (:multichoice) do
        mc = FactoryGirl.create(:multiple_choice, :multi_answer => true)
        mc.create_default_choices
        mc.choices[0].is_correct = true
        mc.choices[0].save
        mc.choices[1].is_correct = true
        mc.choices[1].save
        mc.reload
        mc
      end

      it 'should return a hash with at least one key' do
        expect(multichoice.check("#{first_mc_choice_id}")).to be_a_kind_of Hash
        expect(multichoice.check("#{first_mc_choice_id}").length).to be(1)
      end

      it 'should return a prompt for a nil answer' do
        expect(multichoice.check('')).to eq({ prompt: 'Please select an answer before checking.' })
      end

      it 'should return true for all right answers' do
        expect(multichoice.check("#{multichoice.choices[0].id.to_s},#{multichoice.choices[1].id.to_s}")).to eq({ choice: true })
      end

      it 'should return a prompt for some right answers, but not all' do
        expect(multichoice.check(multichoice.choices[1].id.to_s)).to eq({ prompt: "You're on the right track, but you didn't select all the right answers yet." })
      end

      it 'should return a list of wrong answers' do
        w_choice = multichoice.choices.last
        expect(multichoice.check(w_choice.id.to_s)).to eq({ prompt: "'#{w_choice.choice}' is incorrect" })
      end
    end
  end

  describe '#to_hash' do
    it 'returns a hash with copied attributes' do
      expected = {
        name: multichoice.name,
        prompt: multichoice.prompt,
        custom: multichoice.custom,
        enable_check_answer: multichoice.enable_check_answer,
        multi_answer: multichoice.multi_answer,
        show_as_menu: multichoice.show_as_menu,
        is_prediction: multichoice.is_prediction,
        show_in_featured_question_report: multichoice.show_in_featured_question_report,
        is_half_width: multichoice.is_half_width,
        give_prediction_feedback: multichoice.give_prediction_feedback,
        prediction_feedback: multichoice.prediction_feedback,
        layout: multichoice.layout,
        is_hidden: multichoice.is_hidden,
        hint: multichoice.hint
      }
      expect(multichoice.to_hash).to eq(expected)
    end
  end

  describe '#export' do
    let(:multichoice_json) { multichoice.export.as_json }
    it 'returns json of a multiple choice question' do
      expect(multichoice_json['choices'].length).to eq(multichoice.choices.count)
    end
    it 'preserves is_hidden' do
      multichoice.is_hidden = true
      expect(multichoice_json['is_hidden']).to eq true
    end
  end

  describe "#portal_hash" do
    it 'returns properties supported by Portal' do
      expect(multichoice.portal_hash).to eq(
        type: "multiple_choice",
        id: multichoice.id,
        prompt: multichoice.prompt,
        is_required: multichoice.is_prediction,
        show_in_featured_question_report: multichoice.show_in_featured_question_report,
        choices: multichoice.choices.map { |choice|
          {
            id: choice.id,
            content: choice.choice,
            correct: choice.is_correct
          }
        }
      )
    end
  end

  describe '#duplicate' do
    it 'returns a new instance with copied attributes' do
      expect(multichoice.duplicate).to be_a_new(Embeddable::MultipleChoice).with({
        name: multichoice.name,
        prompt: multichoice.prompt
      })
    end

    it 'copies choices' do
      c = multichoice.choices.first
      expect(c.duplicate).to be_a_new(Embeddable::MultipleChoiceChoice).with( choice: c.choice, prompt: c.prompt, is_correct: c.is_correct )
    end

    it 'has copied choices' do
      expect(multichoice.duplicate.choices.length).to be(multichoice.choices.length)
    end
  end

end
